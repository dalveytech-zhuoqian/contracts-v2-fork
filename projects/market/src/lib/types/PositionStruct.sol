// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Order} from "./OrderStruct.sol";

library Position {
    struct Props {
        // 1
        uint256 size;
        uint256 collateral;
        // 2
        int256 entryFundingRate;
        // 3
        int256 realisedPnl;
        // 4
        uint256 averagePrice;
        bool isLong;
        uint32 lastTime;
        uint16 market;
        uint72 extra0;
    }

    function createPositionFromOrder(Order.Props memory order) internal view returns (Props memory result) {
        // new added
        result.size = order.size;
        result.collateral = order.collateral;
        result.isLong = order.isLong;
        result.market = order.market;
        result.averagePrice = order.price;
        result.lastTime = uint32(block.timestamp);
        return result;
    }

    function calAveragePrice(Props memory position, uint256 sizeDelta, uint256 markPrice, uint256 pnl, bool hasProfit)
        internal
        pure
        returns (uint256)
    {
        uint256 _size = position.size + sizeDelta;
        uint256 _netSize;

        if (position.isLong) {
            _netSize = hasProfit ? _size + pnl : _size - pnl;
        } else {
            _netSize = hasProfit ? _size - pnl : _size + pnl;
        }

        return (markPrice * _size) / _netSize;
    }

    function getLeverage(Props memory position) internal pure returns (uint256) {
        return position.size / position.collateral;
    }

    function getPNL(Props memory position, uint256 price) internal pure returns (bool, uint256) {
        uint256 _priceDelta =
            position.averagePrice > price ? position.averagePrice - price : price - position.averagePrice;
        uint256 _pnl = (position.size * _priceDelta) / position.averagePrice;
        bool _hasProfit;

        if (position.isLong) {
            _hasProfit = price > position.averagePrice;
        } else {
            _hasProfit = position.averagePrice > price;
        }

        return (_hasProfit, _pnl);
    }

    function isExist(Props memory position) internal pure returns (bool) {
        return (position.size > 0);
    }

    // only valid data of position, not include the business logic
    function isValid(Props memory position) internal pure returns (bool) {
        if (position.size == 0) {
            return false;
        }
        if (position.size < position.collateral) {
            return false;
        }

        return true;
    }
}
