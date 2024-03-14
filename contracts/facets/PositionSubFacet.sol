// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
import {Order} from "../lib/types/OrderStruct.sol";

contract PositionSubFacet {
    function decreasePosition(bytes calldata data) external {
        MarketDataTypes.Cache memory _vars = MarketDataTypes.decodeCache(data);
    }

    function liquidate(uint16 market, address accounts, bool _isLong) external {}

    function execSubOrderKey(Order.Props memory order, MarketDataTypes.Cache memory _params) external {
        // decreasePositionFromOrder()
    }

    //========================================================================

    function decreasePositionFromOrder(Order.Props memory order, MarketDataTypes.Cache memory _params) private {}
}
