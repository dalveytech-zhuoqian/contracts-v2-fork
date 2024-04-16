// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;
pragma abicoder v2;

import "../utils/EnumerableValues.sol";
import {OrderHelper, OrderProps} from "./OrderHelper.sol";

library OrderHandler {
    /* is IOrderBook, Ac */
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableValues for EnumerableSet.Bytes32Set;
    using OrderHelper for OrderProps;

    bytes32 constant OB_STORAGE_POSITION = keccak256("blex.orderbook.storage");

    struct OrderStorage {
        mapping(bytes32 storageKey => mapping(bytes32 orderKey => OrderProps)) orders; // keyorder
        mapping(bytes32 storageKey => mapping(address account => uint256)) ordersIndex; // orderID
        mapping(bytes32 storageKey => mapping(address account => uint256)) orderNum; // order
        mapping(bytes32 storageKey => mapping(address account => EnumerableSet.Bytes32Set)) ordersByAccount; // position => order
        mapping(bytes32 storageKey => EnumerableSet.Bytes32Set) orderKeys; // orderkey
    }

    function Storage() internal pure returns (OrderStorage storage fs) {
        bytes32 position = OB_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function generateID(
        bytes32 sk,
        address _acc
    ) internal returns (uint256 retVal) {
        retVal = Storage().ordersIndex[sk][_acc];
        if (retVal == 0) {
            retVal = 1;
        }
        OrderStorage storage $ = Storage();
        unchecked {
            $.ordersIndex[sk][_acc] = retVal + 1;
        }
    }

    function add(bytes32 sk, OrderProps memory order) internal {
        order.updateTime();
        bytes32 key = order.getKey();
        Storage().orders[sk][key] = order;
        Storage().orderKeys[sk].add(key); // ，
        Storage().orderNum[sk][order.account] += 1;
        Storage().ordersByAccount[sk][order.account].add(order.getKey());
    }

    function remove(
        bytes32 sk,
        bytes32 key
    ) internal returns (OrderProps memory _order) {
        _order = Storage().orders[sk][key];
        Storage().orderNum[sk][_order.account] -= 1;
        delete Storage().orders[sk][key];
        Storage().orderKeys[sk].remove(key);
        Storage().ordersByAccount[sk][_order.account].remove(key);
    }

    function set(OrderProps memory order, bytes32 sk) internal {
        order.updateTime(); // block
        bytes32 key = order.getKey();
        OrderStorage storage $ = Storage();
        $.orders[sk][key] = order;
    }

    function removeByAccount(
        uint16 market,
        bool isIncrease,
        bool isLong,
        address account
    ) internal returns (OrderProps[] memory _orders) {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        if (account == address(0)) return _orders;
        bytes32[] memory _ordersKeys = Storage()
        .ordersByAccount[sk][account].values();
        uint256 orderCount = _filterOrders(sk, _ordersKeys);
        uint256 len = _ordersKeys.length;
        // return & del
        _orders = new OrderProps[](orderCount);
        uint256 readIdx;
        for (uint256 i = 0; i < len && readIdx < orderCount; ) {
            bytes32 _orderKey = _ordersKeys[i];
            if (Storage().orderKeys[sk].contains(_orderKey)) {
                OrderProps memory _order = remove(sk, _orderKey);
                _orders[readIdx] = _order;
                unchecked {
                    readIdx++;
                }
            }
            unchecked {
                i++;
            }
        }

        // del key
        delete Storage().ordersByAccount[sk][account];
    }

    //===============================================================
    // view only
    //===============================================================
    function containsKey(bytes32 sk, bytes32 key) internal view returns (bool) {
        return Storage().orderKeys[sk].contains(key);
    }

    function getOrderByIndex(
        uint16 market,
        bool isLong,
        bool isIncrease,
        uint256 index
    ) internal view returns (OrderProps memory) {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        bytes32 key = Storage().orderKeys[sk].at(index);
        return Storage().orders[sk][key];
    }

    function getOrderCount(
        uint16 market,
        bool isLong,
        bool isIncrease
    ) internal view returns (uint256) {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        return Storage().orderKeys[sk].length();
    }

    function getKeyByIndex(
        uint16 market,
        bool isLong,
        bool isIncrease,
        uint256 _index
    ) internal view returns (bytes32) {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        return Storage().orderKeys[sk].at(_index);
    }

    function getKeysInRange(
        bytes32 sk,
        uint256 start,
        uint256 end
    ) internal view returns (bytes32[] memory) {
        return Storage().orderKeys[sk].valuesAt(start, end);
    }

    function getOrders(
        bytes32 storageKey,
        bytes32 orderKey
    ) internal view returns (OrderProps memory _orders) {
        return Storage().orders[storageKey][orderKey];
    }

    function getOrderNum(
        uint16 market,
        bool isLong,
        bool isIncrease,
        address account
    ) internal view returns (uint256) {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        return Storage().orderNum[sk][account];
    }

    //===============================================================
    // private functions
    //===============================================================

    function _filterOrders(
        bytes32 sk,
        bytes32[] memory _ordersKeys
    ) private view returns (uint256 orderCount) {
        uint256 len = _ordersKeys.length;
        for (uint256 i = 0; i < len; i++) {
            bytes32 _orderKey = _ordersKeys[i];
            if (Storage().orderKeys[sk].contains(_orderKey)) {
                orderCount++;
            }
        }
    }
}
