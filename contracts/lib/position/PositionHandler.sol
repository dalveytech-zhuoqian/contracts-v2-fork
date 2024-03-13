// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "../../utils/EnumerableValues.sol";

import {Position} from "./PositionStruct.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library PositionHandler {
    using Position for Position.Props;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeCast for int128;
    using SafeCast for uint128;

    bytes32 constant POS_STORAGE_POSITION = keccak256("blex.position.storage");

    struct PositionStorage {
        // save user position, address -> position
        mapping(bytes32 => mapping(address => Position.Props)) positions;
        // set of position address
        mapping(bytes32 => EnumerableSet.AddressSet) positionKeys;
        // global position
        mapping(bytes32 => Position.Props) globalPositions;
    }

    event UpdatePosition(address indexed account, uint256 size, uint256 collateral);
    event RemovePosition(address indexed account, uint256 size, uint256 collateral);

    function Storage() internal pure returns (PositionStorage storage fs) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function storageKey(uint16 market, bool isLong) public pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, market));
    }

    struct Cache {
        uint16 market;
        address account;
        int256 collateralDelta;
        uint256 sizeDelta;
        uint256 markPrice;
        int256 fundingRate;
        bool isLong;
        bool isOpen;
        bytes32 sk;
        Position.Props position;
        Position.Props globalPosition;
    }

    function increasePosition(bytes calldata _data) external returns (Position.Props memory result) {
        Cache memory cache;
        (
            cache.market,
            cache.account,
            cache.collateralDelta,
            cache.sizeDelta,
            cache.markPrice,
            cache.fundingRate,
            cache.isLong
        ) = abi.decode(_data, (uint16, address, int256, uint256, uint256, int256, bool));
        cache.isOpen = true;
        cache.sk = storageKey(cache.market, cache.isLong);
        cache.position = Storage().positions[cache.sk][cache.account];

        if (cache.position.size == 0) cache.position.averagePrice = uint128(cache.markPrice);

        if (cache.position.size > 0 && cache.sizeDelta > 0) {
            (bool _hasProfit, uint256 _realisedPnl) = cache.position.getPNL(cache.markPrice);
            cache.position.averagePrice =
                cache.position.calAveragePrice(cache.sizeDelta, cache.markPrice, _realisedPnl, _hasProfit);

            int256 _pnl = _hasProfit ? int256(_realisedPnl) : -int256(_realisedPnl);

            result.realisedPnl = _pnl;
            result.averagePrice = cache.position.averagePrice;
        }

        cache.position.collateral = (cache.position.collateral.toInt256() + cache.collateralDelta).toUint256();
        cache.position.entryFundingRate = cache.fundingRate;
        cache.position.size = cache.position.size + cache.sizeDelta;
        cache.position.isLong = cache.isLong;
        cache.position.lastTime = uint32(block.timestamp);

        require(cache.position.isValid(), "positionBook: invalid position");
        set(cache);
        result.size = cache.position.size;
        result.collateral = cache.position.collateral;
    }

    function decreasePosition(bytes calldata _data) external returns (Position.Props memory result) {
        Cache memory cache;
        (cache.market, cache.account, cache.collateralDelta, cache.sizeDelta, cache.fundingRate, cache.isLong) =
            abi.decode(_data, (uint16, address, int256, uint256, int256, bool));
        cache.isOpen = false;
        cache.sk = storageKey(cache.market, cache.isLong);
        cache.position = Storage().positions[cache.sk][cache.account];
        require(cache.position.lastTime != uint32(block.timestamp), "pb:same block");
        require(cache.position.isValid(), "positionBook: invalid position");
        if (cache.collateralDelta > 0) {
            require(cache.position.collateral >= cache.collateralDelta.toUint256(), "positionBook: invalid collateral");
        }
        require(cache.position.size >= cache.sizeDelta, "positionBook: invalid size");
        if (cache.position.size != cache.sizeDelta) {
            cache.position.entryFundingRate = cache.fundingRate;
            cache.position.size = cache.position.size - cache.sizeDelta;
            cache.position.collateral = (cache.position.collateral.toInt256() - cache.collateralDelta).toUint256();
            require(cache.position.isValid(), "positionBook: invalid position");
            set(cache);
            result.size = cache.position.size;
            result.collateral = cache.position.collateral;
        } else {
            remove(cache);
        }
    }

    function liquidatePosition(bytes calldata _data) external returns (Position.Props memory result) {
        Cache memory cache;
        (cache.market, cache.account, cache.markPrice, cache.isLong) =
            abi.decode(_data, (uint16, address, uint256, bool));
        cache.isOpen = false;
        cache.sk = storageKey(cache.market, cache.isLong);
        cache.position = Storage().positions[cache.sk][cache.account];
        require(cache.position.isExist(), "positionBook: position does not exist");

        if (cache.markPrice != 0) {
            (bool _hasProfit, uint256 _realisedPnl) = cache.position.getPNL(cache.markPrice);
            int256 _pnl = _hasProfit ? int256(_realisedPnl) : -int256(_realisedPnl);

            result.realisedPnl = _pnl;
        }
        remove(cache);
        result.size = cache.position.size;
        result.collateral = cache.position.collateral;
    }

    // =====================================================
    //           view only
    // =====================================================
    function getPNL(Position.Props memory _position, uint256 sizeDelta, uint256 markPrice)
        public
        pure
        returns (int256)
    {
        if (_position.size == 0) {
            return 0;
        }

        (bool _hasProfit, uint256 _pnl) = Position.getPNL(_position, markPrice);
        if (sizeDelta != 0) {
            _pnl = (sizeDelta * _pnl) / _position.size;
        }

        return _hasProfit ? int256(_pnl) : -int256(_pnl);
    }

    function _calGlobalPosition(Cache memory cache) private view returns (Position.Props memory) {
        Position.Props memory _position = Storage().globalPositions[cache.sk];
        if (cache.isOpen) {
            uint256 _averagePrice = _getGlobalAveragePrice(_position, cache.sizeDelta, cache.markPrice);
            require(_averagePrice > 100, "pb:invalid global position");
            _position.averagePrice = _averagePrice;
            _position.size += cache.sizeDelta;
            _position.collateral = (_position.collateral.toInt256() + cache.collateralDelta).toUint256();
            _position.isLong = cache.isLong;
            _position.lastTime = uint32(block.timestamp);

            return _position;
        }

        _position.size -= cache.sizeDelta;
        _position.collateral -= cache.collateralDelta.toUint256();

        return _position;
    }

    function _getGlobalAveragePrice(Position.Props memory position, uint256 sizeDelta, uint256 markPrice)
        private
        pure
        returns (uint256)
    {
        if (position.size == 0) {
            return markPrice;
        }
        if (position.size > 0 && sizeDelta > 0) {
            (bool _hasProfit, uint256 _pnl) = position.getPNL(markPrice);
            position.averagePrice = position.calAveragePrice(sizeDelta, markPrice, _pnl, _hasProfit);
        }

        return position.averagePrice;
    }

    function set(Cache memory cache) private {
        cache.globalPosition = _calGlobalPosition(cache);
        Storage().positions[cache.sk][cache.account] = cache.position;
        Storage().globalPositions[cache.sk] = cache.globalPosition;
        Storage().positionKeys[cache.sk].add(cache.account);
        emit UpdatePosition(cache.account, cache.position.size, cache.position.collateral);
    }

    function remove(Cache memory cache) private {
        bool has = Storage().positionKeys[cache.sk].contains(cache.account);
        require(has, "position does not exist");
        Storage().globalPositions[cache.sk] = cache.globalPosition;
        delete Storage().positions[cache.sk][cache.account];
        Storage().positionKeys[cache.sk].remove(cache.account);
        emit RemovePosition(cache.account, cache.position.size, cache.position.collateral);
    }
}
