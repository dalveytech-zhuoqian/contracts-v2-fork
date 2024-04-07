// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Order} from "../lib/types/OrderStruct.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import "../lib/types/Types.sol";
import {OrderHelper, OrderHandler} from "../lib/order/OrderHandler.sol";
import {IOrderFacet} from "../interfaces/IOrderFacet.sol";

// here does not implement core logic
contract OrderFacet is IAccessManaged, IOrderFacet {
    using Order for OrderProps;

    //==========================================================================================
    //       external functions
    //==========================================================================================

    function updateOrder(MarketCache calldata _inputs) external payable override {
        if (_inputs.isCreate) {
            // createOrder
        } else {
            // updateOrder
        }
    }

    function cancelOrder(address account, uint16 market, bool isIncrease, uint256 orderID, bool isLong)
        external
        returns (OrderProps[] memory _orders)
    {
        if (address(this) != msg.sender && account != msg.sender) {
            _checkCanCall(msg.sender, msg.data);
        }
        return _cancelOrder(market, isIncrease, isLong, msg.sender, orderID);
    }

    //==========================================================================================
    //       private functions
    //==========================================================================================

    function _add(MarketCache[] memory _vars) internal returns (OrderProps[] memory _orders) {
        uint256 len = _vars.length;
        _orders = new OrderProps[](len);

        for (uint256 i; i < len;) {
            OrderProps memory _order; //= _vars[i]._order;
            // _order.version = Order.STRUCT_VERSION;
            bytes32 sk = OrderHelper.storageKey(_vars[i].market, _vars[i].isLong, _vars[i].isOpen);
            _order.orderID = uint64(OrderHandler.generateID(sk, _order.account));
            _order = _setupTriggerAbove(_vars[i], _order);
            _orders[i] = _order;
            unchecked {
                ++i;
            }
        }

        if (len == 2) {
            _orders[0].pairId = _orders[1].orderID;
            _orders[1].pairId = _orders[0].orderID;
        }

        for (uint256 i; i < len;) {
            OrderProps memory _order = _orders[i];
            _validInputParams(_order, _vars[i].isOpen, _vars[i].isLong);
            bytes32 sk = OrderHelper.storageKey(_vars[i].market, _vars[i].isLong, _vars[i].isOpen);
            OrderHandler.add(sk, _order);
            unchecked {
                ++i;
            }
        }
    }

    function _validInputParams(OrderProps memory _order, bool _isOpen, bool isLong) private pure {
        if (_isOpen) {
            // _order.validTPSL(isLong);
            require(_order.collateral > 0, "OB:invalid collateral");
        }
        require(_order.account != address(0), "OrderBook:invalid account");
    }

    function _update(MarketCache memory _vars) internal returns (OrderProps memory _order) {
        bytes32 okey = OrderHelper.getKey(_vars.account, _vars.orderId);
        bytes32 sk = OrderHelper.storageKey(_vars.market, _vars.isLong, _vars.isOpen);
        require(OrderHandler.containsKey(sk, okey), "OrderBook:invalid orderKey");
        _order = OrderHandler.getOrders(sk, okey);
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
            _order.sl = _vars.sl;
        }
        _validInputParams(_order, _vars.isOpen, _vars.isLong);
        OrderHandler.set(_order, sk);
    }

    function _cancelOrder(uint16 market, bool isIncrease, bool isLong, address account, uint256 orderID)
        private
        returns (OrderProps[] memory _orders)
    {
        bytes32 sk = OrderHelper.storageKey(market, isLong, isIncrease);
        bytes32 ok = OrderHelper.getKey(account, uint64(orderID));
        // TODO
        // if (false == isIncrease) {
        // bytes32 pairKey = OrderHelper.getPairKey(
        // ); // pairKey
        //     _orders = new OrderProps[](pairKey != bytes32(0) ? 2 : 1); // pairKey0_orders
        //     if (pairKey != bytes32(0)) _orders[1] = _remove(sk, pairKey);
        // } else {
        //     _orders = new OrderProps[](1);
        // } // pairKey0_orders
        // _orders[0] = _remove(sk, ok);
        require(_orders[0].account != address(0), "PositionSubMgr:!account"); // new added
    }

    function _setupTriggerAbove(MarketCache memory _vars, OrderProps memory _order)
        private
        pure
        returns (OrderProps memory)
    {
        if (_vars.isFromMarket) {
            _order.triggerAbove = _vars.isOpen == !_vars.isLong;
            _order.isFromMarket = true;
        } else {
            if (_vars.isOpen) {
                _order.triggerAbove = !_vars.isLong;
            } else if (_vars.triggerAbove == false) {
                _order.triggerAbove = _vars.oraclePrice < _order.price;
            } else {
                _order.triggerAbove = _vars.triggerAbove;
            }
        }
        return _order;
    }
}
