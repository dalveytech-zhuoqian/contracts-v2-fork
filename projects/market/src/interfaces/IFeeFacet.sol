// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeFacet {
    function feeAndRates(uint16 market)
        external
        view
        returns (uint256[] memory fees, int256[] memory fundingRates, int256[] memory _cumulativeFundingRates);
    function updateCumulativeFundingRate(uint16 market, uint256 longSize, uint256 shortSize) external;
    function getFees(bytes calldata data) external view returns (int256[] memory, int256 totalFee);
    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256);
}
