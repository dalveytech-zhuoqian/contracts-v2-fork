// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

contract PositionSubFacet {
    function decreasePosition(bytes calldata data) external {
        //MarketDataTypes.UpdatePositionInputs memory _vars
    }

    function liquidatePositions(bytes calldata data) external {
        (address[] memory accounts, bool _isLong) = abi.decode(data, (address[], bool));
    }

    function execOrderKey(Order.Props memory order, MarketDataTypes.UpdatePositionInputs memory _params) external {
        // decreasePositionFromOrder
    }

    //========================================================================

    function decreasePositionFromOrder(Order.Props memory order, MarketDataTypes.UpdatePositionInputs memory _params)
        private
    {}
}
