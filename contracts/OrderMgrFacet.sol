// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract OrderMgrFacet /* is IAccessManaged */ {

    function updateOrder(
        MarketDataTypes.UpdateOrderInputs memory _vars
    ) external restricted {
    }
 
    function cancelOrderList(
        address _account,
        bool[] memory _isIncreaseList,
        uint256[] memory _orderIDList,
        bool[] memory _isLongList
    ) external restricted {
    }
 
    function sysCancelOrder(
        bytes32[] memory _orderKey,
        bool[] memory _isLong,
        bool[] memory _isIncrease,
        string[] memory reasons
    ) external restricted {
    }
 
}
