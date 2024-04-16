// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {OrderProps, PositionProps} from "./Types.sol";

library Position {
    function createPositionFromOrder(
        OrderProps memory order
    ) internal view returns (PositionProps memory result) {
        // new added
        result.size = order.size;
        result.collateral = order.collateral;
        result.isLong = order.isLong;
        result.market = order.market;
        result.averagePrice = order.price;
        result.lastTime = uint32(block.timestamp);
        return result;
    }

    function calAveragePrice(
        PositionProps memory position,
        uint256 sizeDelta,
        uint256 markPrice,
        uint256 pnl,
        bool hasProfit
    ) internal pure returns (uint256) {
        uint256 _size = position.size + sizeDelta;
        uint256 _netSize;

        if (position.isLong) {
            _netSize = hasProfit ? _size + pnl : _size - pnl;
        } else {
            _netSize = hasProfit ? _size - pnl : _size + pnl;
        }

        return (markPrice * _size) / _netSize;
    }

    function calLeverage(
        PositionProps memory position
    ) internal pure returns (uint256) {
        return position.size / position.collateral;
    }

    function calPNL(
        PositionProps memory position,
        uint256 price
    ) internal pure returns (bool, uint256) {
        uint256 _priceDelta = position.averagePrice > price
            ? position.averagePrice - price
            : price - position.averagePrice;
        uint256 _pnl = (position.size * _priceDelta) / position.averagePrice;
        bool _hasProfit;

        if (position.isLong) {
            _hasProfit = price > position.averagePrice;
        } else {
            _hasProfit = position.averagePrice > price;
        }

        return (_hasProfit, _pnl);
    }

    function isExist(
        PositionProps memory position
    ) internal pure returns (bool) {
        return (position.size > 0);
    }

    // only valid data of position, not include the business logic
    function isValid(
        PositionProps memory position
    ) internal pure returns (bool) {
        if (position.size == 0) {
            return false;
        }
        if (position.size < position.collateral) {
            return false;
        }

        return true;
    }
}
