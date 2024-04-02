// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

// import "../IMarketCallBackIntl.sol";

library MarketHelper {
    /**
     * @dev Calculates the delta collateral for decreasing a position.
     * @return deltaCollateral The calculated delta collateral.
     */
    function getDecreaseDeltaCollateral(bool isKeepLev, uint256 size, uint256 dSize, uint256 collateral)
        internal
        pure
        returns (uint256 deltaCollateral)
    {
        if (isKeepLev) {
            deltaCollateral = (collateral * dSize) / size;
        } else {
            deltaCollateral = 0;
        }
    }
}
