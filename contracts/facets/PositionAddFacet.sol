// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import {MarketDataTypes} from "../lib/MarketDataTypes.sol";
import {Order} from "../lib/order/OrderStruct.sol";

contract PositionAddFacet { /* is MarketStorage, ReentrancyGuard, Ac */
    function increasePosition(bytes calldata _data) external {
        MarketDataTypes.Cache memory _inputs = MarketDataTypes.decodeCache(_data);
    }

    function execAddOrderKey(Order.Props memory exeOrder, MarketDataTypes.Cache memory _params) external {}
}
