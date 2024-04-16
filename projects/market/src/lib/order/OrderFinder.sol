// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import "../utils/EnumerableValues.sol";
import {OrderHandler, OrderHelper, OrderProps} from "./OrderHandler.sol";
import {OrderFinderCache} from "../../interfaces/IMarketFacet.sol";

library OrderFinder {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableValues for EnumerableSet.Bytes32Set;
    using OrderHelper for OrderProps;
    using OrderHelper for OrderProps;

    function getExecutableOrdersByPrice(
        OrderFinderCache memory cache
    ) internal view returns (OrderProps[] memory _orders) {
        cache.storageKey = OrderHelper.storageKey(
            cache.market,
            cache.isLong,
            cache.isIncrease
        );
        require(cache.oraclePrice > 0, "oraclePrice zero");
        bytes32[] memory keys = OrderHandler.getKeysInRange(
            cache.storageKey,
            cache.start,
            cache.end
        );
        uint256 _listCount;
        uint256 _len = keys.length;
        for (uint256 index; index < _len; ) {
            bytes32 key = keys[index];
            OrderProps memory _open = OrderHandler.getOrders(
                cache.storageKey,
                key
            );
            if (
                (_open.isMarkPriceValid(cache.oraclePrice) &&
                    key != bytes32(0)) || _open.isFromMarket
            ) {
                unchecked {
                    ++_listCount;
                }
            }
            unchecked {
                ++index;
            }
        }
        _orders = new OrderProps[](_listCount);

        uint256 _orderKeysIdx;
        for (uint256 index; index < _len; ) {
            bytes32 key = keys[index];
            OrderProps memory _open = OrderHandler.getOrders(
                cache.storageKey,
                key
            );
            if (
                (_open.isMarkPriceValid(cache.oraclePrice) &&
                    key != bytes32(0)) || _open.isFromMarket
            ) {
                _orders[_orderKeysIdx] = _open;
                unchecked {
                    ++_orderKeysIdx;
                }
            }
            unchecked {
                ++index;
            }
        }
    }
}
