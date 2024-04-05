// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import "../utils/EnumerableValues.sol";
import {Position, PositionProps} from "./../types/PositionStruct.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {PositionStorage, PositionCache} from "./PositionStorage.sol";

library PositionHandler {
    using Position for PositionProps;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using SafeCast for uint256;
    using SafeCast for int256;
    using SafeCast for int128;
    using SafeCast for uint128;

    function increasePosition(PositionCache memory cache) internal returns (PositionProps memory result) {
        cache.isOpen = true;
        cache.sk = PositionStorage.storageKey(cache.market, cache.isLong);
        cache.position = PositionStorage.Storage().positions[cache.sk][cache.account];

        if (cache.position.size == 0) cache.position.averagePrice = uint128(cache.markPrice);

        if (cache.position.size > 0 && cache.sizeDelta > 0) {
            (bool _hasProfit, uint256 _realisedPnl) = cache.position.calPNL(cache.markPrice);
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
        cache.globalPosition = _calGlobalPosition(cache);
        PositionStorage.set(cache);
        result.size = cache.position.size;
        result.collateral = cache.position.collateral;
    }

    function decreasePosition(PositionCache memory cache) internal returns (PositionProps memory result) {
        cache.isOpen = false;
        cache.sk = PositionStorage.storageKey(cache.market, cache.isLong);
        cache.position = PositionStorage.Storage().positions[cache.sk][cache.account];
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
            cache.globalPosition = _calGlobalPosition(cache);
            PositionStorage.set(cache);
            result.size = cache.position.size;
            result.collateral = cache.position.collateral;
        } else {
            PositionStorage.remove(cache);
        }
    }

    function liquidatePosition(PositionCache memory cache) internal returns (PositionProps memory result) {
        cache.isOpen = false;
        cache.sk = PositionStorage.storageKey(cache.market, cache.isLong);
        cache.position = PositionStorage.Storage().positions[cache.sk][cache.account];
        require(cache.position.isExist(), "positionBook: position does not exist");
        if (cache.markPrice != 0) {
            (bool _hasProfit, uint256 _realisedPnl) = cache.position.calPNL(cache.markPrice);
            int256 _pnl = _hasProfit ? int256(_realisedPnl) : -int256(_realisedPnl);

            result.realisedPnl = _pnl;
        }
        PositionStorage.remove(cache);
        result.size = cache.position.size;
        result.collateral = cache.position.collateral;
    }

    // =====================================================
    //           private only
    // =====================================================

    function _calGlobalPosition(PositionCache memory cache) private view returns (PositionProps memory) {
        PositionProps memory _position = PositionStorage.Storage().globalPositions[cache.sk];
        if (cache.isOpen) {
            uint256 _averagePrice = _calGlobalAveragePrice(_position, cache.sizeDelta, cache.markPrice);
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

    function _calGlobalAveragePrice(PositionProps memory position, uint256 sizeDelta, uint256 markPrice)
        private
        pure
        returns (uint256)
    {
        if (position.size == 0) {
            return markPrice;
        }
        if (position.size > 0 && sizeDelta > 0) {
            (bool _hasProfit, uint256 _pnl) = position.calPNL(markPrice);
            position.averagePrice = position.calAveragePrice(sizeDelta, markPrice, _pnl, _hasProfit);
        }

        return position.averagePrice;
    }
}
