// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

contract PositionAddFacet { /* is MarketStorage, ReentrancyGuard, Ac */
    function increasePositionWithOrders(MarketDataTypes.UpdatePositionInputs memory _inputs) public {}

    function execOrderKey(Order.Props memory exeOrder, MarketDataTypes.UpdatePositionInputs memory _params) external {}
}
