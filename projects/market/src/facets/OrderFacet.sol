// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma abicoder v2;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./funcs.sol";

import {PositionFacetBase} from "./PositionFacetBase.sol";

//================================================================
//handlers
import {MarketHandler} from "../lib/market/MarketHandler.sol";
//================================================================
//interfaces
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IOrderFacet} from "../interfaces/IOrderFacet.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
//================================================================
//data types
import {OrderHelper, OrderHandler} from "../lib/order/OrderHandler.sol";
import "../lib/types/Types.sol";
import {Validations} from "../lib/types/Valid.sol";

// here does not implement core logic
contract OrderFacet is IAccessManaged, IOrderFacet, PositionFacetBase {
    using OrderHelper for OrderProps;
    using SafeERC20 for IERC20Metadata;

    //==========================================================================================
    //       external functions
    //==========================================================================================
    function getPrice(bool _isMax) private view returns (uint256) {}

    function updateOrder(MarketCache memory _inputs) external payable override {
        MarketCache[] memory orderVars = new MarketCache[](1);
        orderVars[0] = _inputs;
        if (_inputs.isOpen && _inputs.isCreate) {
            Validations.validPayMax(_inputs.market, _inputs.pay);
        }
        _inputs.oraclePrice = getPrice(_inputs.isLong == _inputs.isOpen);
        if (_inputs.isFromMarket) {
            _inputs.price = Validations.calSlippagePrice(_inputs);
        }
        if (_inputs.isCreate) {
            // createOrder
            transferIn(
                MarketHandler.collateralToken(_inputs.market), msg.sender, address(this), _inputs.collateralDelta
            );
            if (_inputs.isOpen) {
                //todo
                // (, int256 totalFee) = _feeFacet().getFeesReceivable(_inputs, 0);
                // Validations.validIncreaseOrder(_inputs, totalFee);
                _inputs.collateral = _inputs.pay;
            } else {
                int256 fees = _feeFacet().getOrderFees(_inputs);
                PositionProps memory _position =
                    _positionFacet().getPosition(_inputs.market, _inputs.account, _inputs.oraclePrice, _inputs.isLong);
                //todo
                // _inputs.collateral =
                //     getDecreaseDeltaCollateral(_inputs.extra3 > 0, _position.size, _inputs.size, _position.collateral);
                Validations.validDecreaseOrder(
                    _inputs.market,
                    _position.collateral,
                    _inputs.collateralDelta,
                    _position.size,
                    _inputs.sizeDelta,
                    fees,
                    OrderHandler.getOrderNum(_inputs.market, _inputs.isLong, _inputs.isOpen, _inputs.account)
                );
            }
        }

        OrderProps memory _order;
        if (_inputs.isCreate) {
            _order = _add(orderVars)[0];
        } else {
            _order = _update(_inputs);
        }
        // MarketLib.afterUpdateOrder(
        //     _vars,
        //     pluginGasLimit,
        //     plugins,
        //     collateralToken,
        //     address(this)
        // );
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

    function transferIn(address tokenAddress, address _from, address _to, uint256 _tokenAmount) private {
        // If the token amount is 0, return.
        if (_tokenAmount == 0) return;
        // Retrieve the token contract.
        IERC20Metadata coll = IERC20Metadata(tokenAddress);
        // Format the collateral amount based on the token's decimals and transfer the tokens.
        coll.safeTransferFrom(_from, _to, formatCollateral(_tokenAmount, tokenAddress));
    }

    function _addOrders(MarketCache[] memory _inputs) external onlySelf returns (OrderProps[] memory _orders) {
        return _add(_inputs);
    }

    function _add(MarketCache[] memory _inputs) private returns (OrderProps[] memory _orders) {
        uint256 len = _inputs.length;
        _orders = new OrderProps[](len);

        for (uint256 i; i < len;) {
            OrderProps memory _order; //= _inputs[i].order;
            // _order.version = Order.STRUCT_VERSION;
            bytes32 sk = OrderHelper.storageKey(_inputs[i].market, _inputs[i].isLong, _inputs[i].isOpen);
            _order.orderID = uint64(OrderHandler.generateID(sk, _order.account));
            _order = _setupTriggerAbove(_inputs[i], _order);
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
            _validInputParams(_order, _inputs[i].isOpen, _inputs[i].isLong);
            bytes32 sk = OrderHelper.storageKey(_inputs[i].market, _inputs[i].isLong, _inputs[i].isOpen);
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

    function _update(MarketCache memory _inputs) internal returns (OrderProps memory _order) {
        bytes32 okey = OrderHelper.getKey(_inputs.account, _inputs.orderId);
        bytes32 sk = OrderHelper.storageKey(_inputs.market, _inputs.isLong, _inputs.isOpen);
        require(OrderHandler.containsKey(sk, okey), "OrderBook:invalid orderKey");
        _order = OrderHandler.getOrders(sk, okey);
        require(_order.version == OrderHelper.STRUCT_VERSION, "OrderBook:wrong version"); // ，
        _order.price = _inputs.price;

        //******************************************************************
        // 2023/10/07:  trigger
        if (!_inputs.isOpen) {
            _order.triggerAbove = _inputs.triggerAbove;
        } else {
            _order.isKeepLevTP = _inputs.isKeepLevTP;
            _order.isKeepLevSL = _inputs.isKeepLevSL;
        }

        //******************************************************************
        _order = _setupTriggerAbove(_inputs, _order); // order
        if (_inputs.isOpen) {
            _order.tp = _inputs.tp;
            _order.sl = _inputs.sl;
        }
        _validInputParams(_order, _inputs.isOpen, _inputs.isLong);
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

    function _setupTriggerAbove(MarketCache memory _inputs, OrderProps memory _order)
        private
        pure
        returns (OrderProps memory)
    {
        if (_inputs.isFromMarket) {
            _order.triggerAbove = _inputs.isOpen == !_inputs.isLong;
            _order.isFromMarket = true;
        } else {
            if (_inputs.isOpen) {
                _order.triggerAbove = !_inputs.isLong;
            } else if (_inputs.triggerAbove == false) {
                _order.triggerAbove = _inputs.oraclePrice < _order.price;
            } else {
                _order.triggerAbove = _inputs.triggerAbove;
            }
        }
        return _order;
    }
}
