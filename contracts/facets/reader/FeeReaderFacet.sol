// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeReaderFacet { /* is IAccessManaged */
    // =================================================================================
    // read only
    // =================================================================================

    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256) {}

    function feeAndRates(bytes calldata data) external view returns (bytes memory returnData) {
        // uint16 market, uint8 feeType
        // return uint256 feeAndRate
    }

    function getExecFee(uint16 market) external view returns (uint256) {}

    function getFees(bytes memory data) external view returns (int256[] memory fees) {
        // MarketDataTypes.UpdatePositionInputs memory params,
        // Position.Props memory position
    }

    function getFundingRate(uint16 market, bool isLong) external view returns (int256) {}

    function getOrderFees(bytes memory data) external view returns (int256 fees) {
        // MarketDataTypes.UpdateOrderInputs memory params
    }

}
