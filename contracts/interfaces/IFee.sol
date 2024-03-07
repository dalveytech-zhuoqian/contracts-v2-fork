// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFee {
    function collectFees(bytes memory data) external;
    function payoutFees(bytes memory data) external;
    function updateCumulativeFundingRate(bytes memory data) external;
    function addSkipTime(uint256 start, uint256 end) external;
    function feeVaultWithdraw(address token, address to, uint256 amount) external;

    // =================================================================================
    // read only
    // =================================================================================
    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256);
    function feeAndRates(bytes calldata data) external view returns (bytes memory returnData);
    function getExecFee(uint16 market) external view returns (uint256);
    function getFees(bytes memory data) external view returns (int256[] memory fees);
    function getFundingRate(uint16 market, bool isLong) external view returns (int256);
    function getOrderFees(bytes memory data) external view returns (int256 fees);
    function getGlobalOpenInterest() external view returns (uint256 _globalSize);
}
