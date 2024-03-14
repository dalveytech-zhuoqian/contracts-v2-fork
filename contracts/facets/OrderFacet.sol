// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import {MarketDataTypes} from "../lib/MarketDataTypes.sol";
import {Order} from "../lib/order/OrderStruct.sol";

contract OrderFacet { /* is IAccessManaged */
    function updateOrder(bytes calldata data) external {
        (MarketDataTypes.Cache memory _inputs) = abi.decode(data, (MarketDataTypes.Cache));
        if (_inputs.isCreate) {
            // createOrder
        } else {
            // updateOrder
        }
    }

    function cancelOrder(address markets, bool isIncrease, uint256 orderID, bool isLong) external {
        // user cancel
        _cancelOrder(msg.sender, markets, isIncrease, orderID, isLong);
    }

    function sysCancelOrder(address user, address markets, bool isIncrease, uint256 orderID, bool isLong) external {
        if (msg.sender == address(this)) {
            // called by market
        } else {
            // system cancel
        }
        _cancelOrder(user, markets, isIncrease, orderID, isLong);
    }

    function _cancelOrder(address user, address markets, bool isIncrease, uint256 orderID, bool isLong) internal {
        // todo
    }
}