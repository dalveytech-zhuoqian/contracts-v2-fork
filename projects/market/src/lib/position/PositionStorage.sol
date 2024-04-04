// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import "../utils/EnumerableValues.sol";
import {Position} from "./../types/PositionStruct.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library PositionStorage {
    using Position for Position.Props;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeCast for int128;
    using SafeCast for uint128;

    bytes32 constant POS_STORAGE_POSITION = keccak256("blex.position.storage");

    event UpdatePosition(address indexed account, uint256 size, uint256 collateral);
    event RemovePosition(address indexed account, uint256 size, uint256 collateral);

    struct StorageStruct {
        // save user position, address -> position
        mapping(bytes32 => mapping(address => Position.Props)) positions;
        // set of position address
        mapping(bytes32 => EnumerableSet.AddressSet) positionKeys;
        // global position
        mapping(bytes32 => Position.Props) globalPositions;
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

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function storageKey(uint16 market, bool isLong) internal pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, market));
    }

    // =====================================================
    //           write
    // =====================================================

    function set(Cache memory cache) internal {
        Storage().positions[cache.sk][cache.account] = cache.position;
        Storage().globalPositions[cache.sk] = cache.globalPosition;
        Storage().positionKeys[cache.sk].add(cache.account);
        emit UpdatePosition(cache.account, cache.position.size, cache.position.collateral);
    }

    function remove(Cache memory cache) internal {
        bool has = Storage().positionKeys[cache.sk].contains(cache.account);
        require(has, "position does not exist");
        Storage().globalPositions[cache.sk] = cache.globalPosition;
        delete Storage().positions[cache.sk][cache.account];
        Storage().positionKeys[cache.sk].remove(cache.account);
        emit RemovePosition(cache.account, cache.position.size, cache.position.collateral);
    }
    // =====================================================
    //           view only
    // =====================================================

    function getAccountSizesForBothDirections(uint16 market, address account)
        internal
        view
        returns (uint256 sizeLong, uint256 sizeShort)
    {
        sizeLong = _getPosition(market, account, true).size;
        sizeShort = _getPosition(market, account, false).size;
    }

    function getGlobalPosition(uint16 market, bool isLong) internal view returns (Position.Props memory) {
        return _getGlobalPosition(storageKey(market, isLong));
    }

    function getMarketSizesForBothDirections(uint16 market)
        internal
        view
        returns (uint256 globalSizeLong, uint256 globalSizeShort)
    {
        StorageStruct storage ps = Storage();
        globalSizeLong = ps.globalPositions[storageKey(market, true)].size;
        globalSizeShort = ps.globalPositions[storageKey(market, false)].size;
    }

    function getMarketPNLInBoth(uint16 market, uint256 longPrice, uint256 shortPrice) internal view returns (int256) {
        int256 _totalPNL = _getMarketPNL(market, longPrice, true);
        _totalPNL += _getMarketPNL(market, shortPrice, false);
        return _totalPNL;
    }

    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        internal
        view
        returns (Position.Props memory)
    {
        //todo
        return Storage().positions[storageKey(market, isLong)][account];
    }

    function getPositionsForBothDirections(uint16 market, address account)
        internal
        view
        returns (Position.Props memory posLong, Position.Props memory posShort)
    {
        StorageStruct storage ps = Storage();
        posLong = ps.positions[storageKey(market, true)][account];
        posShort = ps.positions[storageKey(market, false)][account];
    }

    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        internal
        view
        returns (int256)
    {
        Position.Props memory _position = getPosition(market, account, markPrice, isLong);
        return _calPNL(_position, sizeDelta, markPrice);
    }

    //==========================================================
    //    private
    //==========================================================

    function _getGlobalPosition(bytes32 sk) private view returns (Position.Props memory _position) {
        // DONE
        _position = Storage().globalPositions[sk];
    }

    function _getMarketPNL(uint16 market, uint256 markPrice, bool isLong) private view returns (int256) {
        // DONE
        Position.Props memory _position = _getGlobalPosition(storageKey(market, isLong));
        if (_position.size == 0) {
            return 0;
        }

        (bool _hasProfit, uint256 _pnl) = _position.calPNL(markPrice);
        return _hasProfit ? int256(_pnl) : -int256(_pnl);
    }

    function _getPosition(uint16 market, address account, bool isLong) internal view returns (Position.Props memory) {
        // DONE
        return Storage().positions[storageKey(market, isLong)][account];
    }

    function _getPositionAndCalcPNL(uint16 market, address account, uint256 markPrice, bool isLong)
        private
        view
        returns (Position.Props memory)
    {
        // DONE
        Position.Props memory _position = _getPosition(market, account, isLong);

        if (markPrice == 0) {
            return _position;
        }

        if (_position.size != 0) {
            (bool _hasProfit, uint256 _realisedPnl) = _position.calPNL(markPrice);
            int256 _pnl = _hasProfit ? int256(_realisedPnl) : -int256(_realisedPnl);
            _position.realisedPnl = _pnl;
        }

        return _position;
    }

    function _calPNL(Position.Props memory _position, uint256 sizeDelta, uint256 markPrice)
        private
        pure
        returns (int256)
    {
        if (_position.size == 0) {
            return 0;
        }

        (bool _hasProfit, uint256 _pnl) = Position.calPNL(_position, markPrice);
        if (sizeDelta != 0) {
            _pnl = (sizeDelta * _pnl) / _position.size;
        }

        return _hasProfit ? int256(_pnl) : -int256(_pnl);
    }
}
