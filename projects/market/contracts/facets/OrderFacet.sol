// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma abicoder v2;

import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
import {Order} from "../lib/types/OrderStruct.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract OrderFacet is IAccessManaged {
    function updateOrder(bytes calldata data) external payable {
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

    function sysCancelOrder(address user, address markets, bool isIncrease, uint256 orderID, bool isLong)
        external
        restricted
    {
        if (msg.sender == address(this)) {
            // called by market
        } else {
            // system cancel
        }
        _cancelOrder(user, markets, isIncrease, orderID, isLong);
    }
    //==========================================================================================
    //       private functions
    //==========================================================================================

    function _cancelOrder(address user, address markets, bool isIncrease, uint256 orderID, bool isLong) internal {
        // todo
    }
}
