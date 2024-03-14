// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import "../utils/EnumerableValues.sol";
import {Order} from "../types/OrderStruct.sol";
import {MarketDataTypes} from "../types/MarketDataTypes.sol";
import {OrderHandler} from "./OrderHandler.sol";
import {OrderHelper} from "./OrderHelper.sol";

library OrderFinder {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableValues for EnumerableSet.Bytes32Set;
    using Order for Order.Props;

    struct Cache {
        uint16 market;
        bool isLong;
        bool isIncrease;
        uint256 start;
        uint256 end;
        bool isOpen;
        uint256 oraclePrice;
        bytes32 storageKey;
    }

    function getExecutableOrdersByPrice(bytes calldata _data) external view returns (Order.Props[] memory _orders) {
        Cache memory cache;
        (cache.market, cache.isLong, cache.isIncrease, cache.start, cache.end, cache.isOpen, cache.oraclePrice) =
            abi.decode(_data, (uint16, bool, bool, uint256, uint256, bool, uint256));
        cache.storageKey = OrderHelper.storageKey(cache.market, cache.isLong, cache.isIncrease);
        require(cache.oraclePrice > 0, "oraclePrice zero");
        bytes32[] memory keys = OrderHandler.getKeys(cache.storageKey, start, end);
        uint256 _listCount;
        uint256 _len = keys.length;
        for (uint256 index; index < _len;) {
            bytes32 key = keys[index];
            Order.Props memory _open = OrderHandler.orders(cache.storageKey, key);
            if ((_open.isMarkPriceValid(_oraclePrice) && key != bytes32(0)) || _open.isFromMarket) {
                unchecked {
                    ++_listCount;
                }
                if (_listCount >= maxSize) {
                    break;
                }
            }
            unchecked {
                ++index;
            }
        }
        _orders = new Order.Props[](_listCount);

        uint256 _orderKeysIdx;
        for (uint256 index; index < _len;) {
            bytes32 key = keys[index];
            Order.Props memory _open = OrderHandler.orders(cache.storageKey, key);
            if ((_open.isMarkPriceValid(_oraclePrice) && key != bytes32(0)) || _open.isFromMarket) {
                _orders[_orderKeysIdx] = _open;
                unchecked {
                    ++_orderKeysIdx;
                }
                if (_orderKeysIdx >= maxSize) {
                    break;
                }
            }
            unchecked {
                ++index;
            }
        }
    }
}
