// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MarketCache, PositionProps} from "../lib/types/Types.sol";

interface IFeeFacet {
    function _collectFees(bytes calldata _data) external;
    function _updateCumulativeFundingRate(uint16 market, uint256 longSize, uint256 shortSize) external;
    //================================================================
    // view functions
    //================================================================

    function getFeeAndRatesOfMarket(uint16 market)
        external
        view
        returns (uint256[] memory fees, int256[] memory fundingRates, int256[] memory _cumulativeFundingRates);

    function getOrderFees(MarketCache calldata data) external view returns (int256 fees);

    function getFeesReceivable(MarketCache calldata params, PositionProps calldata position)
        external
        view
        returns (int256[] memory fees, int256 totalFee);

    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256);
    function _addFee(uint16 market, bytes calldata fee) external;
}
