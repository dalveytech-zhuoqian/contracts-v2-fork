// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
import {Order} from "../lib/types/OrderStruct.sol";

import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract PositionSubFacet is IAccessManaged {
    function liquidate(uint16 market, address accounts, bool _isLong) external restricted {}

    function execSubOrderKey(Order.Props memory order, MarketDataTypes.Cache memory _params) external restricted {
        // decreasePositionFromOrder()
    }

    //========================================================================
    // private functions
    //========================================================================

    function decreasePositionFromOrder(Order.Props memory order, MarketDataTypes.Cache memory _params) private {}
}
