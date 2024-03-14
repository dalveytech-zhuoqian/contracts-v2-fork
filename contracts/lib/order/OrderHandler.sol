// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "../utils/EnumerableValues.sol";
import {Order} from "../types/OrderStruct.sol";
import {MarketDataTypes} from "../types/MarketDataTypes.sol";
import {OrderHelper} from "./OrderHelper.sol";

library OrderHandler { /* is IOrderBook, Ac */
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableValues for EnumerableSet.Bytes32Set;
    using Order for Order.Props;

    bytes32 constant OB_STORAGE_POSITION = keccak256("blex.orderbook.storage");

    struct OrderStorage {
        mapping(bytes32 => mapping(bytes32 => Order.Props)) orders; // keyorder
        mapping(bytes32 => mapping(address => uint256)) ordersIndex; // orderID
        mapping(bytes32 => mapping(address => uint256)) orderNum; // order
        mapping(bytes32 => mapping(address => EnumerableSet.Bytes32Set)) ordersByAccount; // position => order
        mapping(bytes32 => EnumerableSet.Bytes32Set) orderKeys; // orderkey
    }

    function Storage() internal pure returns (OrderStorage storage fs) {
        bytes32 position = OB_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function add(MarketDataTypes.Cache[] memory _vars) internal returns (Order.Props[] memory _orders) {
        uint256 len = _vars.length;
        _orders = new Order.Props[](len);
        for (uint256 i; i < len;) {
            Order.Props memory _order = _vars[i]._order;
            _order.version = Order.STRUCT_VERSION;
            bytes32 sk = OrderHelper.storageKey(_vars.market, _vars.isLong, _vars.isIncrease);
            _order.orderID = uint64(_generateID(sk, _order.account));
            _order = _setupTriggerAbove(_vars[i], _order);
            _orders[i] = _order;
            unchecked {
                ++i;
            }
        }

        if (len == 2) {
            _orders[0].pairKey = _orders[1].orderID;
            _orders[1].pairKey = _orders[0].orderID;
        }

        for (uint256 i; i < len;) {
            Order.Props memory _order = _orders[i];
            _validInputParams(_order, _vars[i].isOpen);
            bytes32 sk = OrderHelper.storageKey(_vars.market, _vars.isLong, _vars.isIncrease);
            _add(sk, _order);
            unchecked {
                ++i;
            }
        }
    }

    function update(MarketDataTypes.Cache memory _vars) internal returns (Order.Props memory _order) {
        bytes32 okey = OrderHelper.getKey(_vars.account, _vars.orderId);
        require(containsKey(okey), "OrderBook:invalid orderKey");
        _order = orders(okey);
        require(_order.version == Order.STRUCT_VERSION, "OrderBook:wrong version"); // ，
        _order.price = _vars.price;

        //******************************************************************
        // 2023/10/07:  trigger
        if (!_vars.isOpen) {
            _order.triggerAbove = _vars.triggerAbove;
        } else {
            _order.isKeepLevTP = _vars.isKeepLevTP;
            _order.isKeepLevSL = _vars.isKeepLevSL;
        }

        //******************************************************************
        _order = _setupTriggerAbove(_vars, _order); // order
        if (_vars.isOpen) {
            _order.tp = _vars.tp;
            _order.tl = _vars.sl;
        }
        _validInputParams(_order, _vars.isOpen);
        os.set(_order);
    }

    function remove(uint16 market, bool isIncrease, bool isLong, address account, uint256 orderID)
        public
        returns (Order.Props[] memory _order)
    {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        bytes32 ok = OrderLib.getKey(account, uint64(orderID));
        if (false == isOpen) {
            bytes32 pairKey = orders(sk, ok).pairKey; // pairKey
            _orders = new Order.Props[](pairKey != bytes32(0) ? 2 : 1); // pairKey0_orders
            if (pairKey != bytes32(0)) _orders[1] = _remove(sk, pairKey);
        } else {
            _orders = new Order.Props[](1);
        } // pairKey0_orders
        _orders[0] = _remove(sk, ok);
    }

    function removeByAccount(uint16 market, bool isOpen, bool isLong, address account)
        internal
        returns (Order.Props[] memory _orders)
    {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        if (account == address(0)) return _orders;
        bytes32[] memory _ordersKeys = Storage().ordersByAccount[sk][account].values();
        uint256 orderCount = _filterOrders(sk, _ordersKeys);
        uint256 len = _ordersKeys.length;
        // return & del
        _orders = new Order.Props[](orderCount);
        uint256 readIdx;
        for (uint256 i = 0; i < len && readIdx < orderCount;) {
            bytes32 _orderKey = _ordersKeys[i];
            if (Storage().orderKeys[sk].contains(_orderKey)) {
                Order.Props memory _order = _remove(sk, _orderKey);
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
    function orders(bytes32 storageKey, bytes32 orderKey) internal view returns (Order.Props[] memory _orders) {
        return Storage().orders[storageKey][orderKey];
    }

    function getByIndex(uint16 market, bool isLong, bool isIncrease, uint256 index)
        internal
        view
        returns (Order.Props memory)
    {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        bytes32 key = Storage().orderKeys[sk].at(index);
        return Storage().orders[sk][key];
    }

    function containsKey(bytes32 sk, bytes32 key) internal view returns (bool) {
        return Storage().orderKeys[sk].contains(key);
    }

    function getCount(uint16 market, bool isLong, bool isIncrease) internal view returns (uint256) {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        return Storage().orderKeys[sk].length();
    }

    function getKey(uint16 market, bool isLong, bool isIncrease, uint256 _index) internal view returns (bytes32) {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        return Storage().orderKeys[sk].at(_index);
    }

    function getKeys(bytes32 sk, uint256 start, uint256 end) internal view returns (bytes32[] memory) {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        return Storage().orderKeys[sk].valuesAt(start, end);
    }

    //===============================================================
    // private functions
    //===============================================================

    function _remove(bytes32 sk, bytes32 key) private returns (Order.Props memory _order) {
        _order = Storage().orders[sk][key];
        Storage().orderNum[sk][_order.account] -= 1;
        delete Storage().orders[sk][key];
        Storage().orderKeys[sk].remove(key);
        Storage().ordersByAccount[sk][_order.account].remove(key);
    }

    function _filterOrders(bytes32 sk, bytes32[] memory _ordersKeys) private view returns (uint256 orderCount) {
        uint256 len = _ordersKeys.length;
        for (uint256 i = 0; i < len; i++) {
            bytes32 _orderKey = _ordersKeys[i];
            if (Storage().orderKeys[sk].contains(_orderKey)) {
                orderCount++;
            }
        }
    }

    function _add(bytes32 sk, Order.Props memory order) private {
        order.updateTime();
        bytes32 key = order.getKey();
        Storage().orders[sk][key] = order;
        Storage().orderKeys[sk].add(key); // ，
        Storage().orderNum[sk][order.account] += 1;
        Storage().ordersByAccount[sk][order.account].add(order.getKey());
    }

    function _validInputParams(Order.Props memory _order, bool _isOpen, bool isLong) private pure {
        if (_isOpen) {
            _order.validTPSL(isLong);
            require(_order.collateral > 0, "OB:invalid collateral");
        }
        require(_order.account != address(0), "OrderBook:invalid account");
        require(_order.triggerAbove != 0, "OB:trigger above init");
    }

    function _setupTriggerAbove(MarketDataTypes.Cache memory _vars, Order.Props memory _order)
        private
        pure
        returns (Order.Props memory)
    {
        if (_vars.isFromMarket()) {
            _order.triggerAbove = _vars.isOpen == !_vars._isLong;
            _order.isFromMarket = true;
        } else {
            if (_vars.isOpen) {
                _order.triggerAbove = !_vars._isLong;
            } else if (_vars._order.triggerAbove == 0) {
                _order.triggerAbove = _vars._oraclePrice < _order.price;
            } else {
                _order.triggerAbove = _vars._order.triggerAbove;
            }
        }
        return _order;
    }

    function _generateID(bytes32 sk, address _acc) private returns (uint256 retVal) {
        retVal = Storage().ordersIndex[sk][_acc];
        if (retVal == 0) {
            retVal = 1;
        }
        unchecked {
            ordersIndex[sk][_acc] = retVal + 1;
        }
    }
}
