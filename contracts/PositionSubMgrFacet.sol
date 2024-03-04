// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

contract PositionSubMgrFacet {
  
    function decreasePosition(
        MarketDataTypes.UpdatePositionInputs memory _vars
    ) external {
    }
 
    function liquidatePositions(
        address[] memory accounts,
        bool _isLong
    ) external {
    }

    function execOrderKey(
        Order.Props memory order,
        MarketDataTypes.UpdatePositionInputs memory _params
    ) external {
    }
   
}
