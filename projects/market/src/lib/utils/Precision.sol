// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

library Precision {
    uint256 internal constant BASIS_POINTS_DIVISOR = 100000000;
    uint256 internal constant FEE_RATE_PRECISION_DECIMALS = 8;
    uint256 internal constant FEE_RATE_PRECISION = 10 ** FEE_RATE_PRECISION_DECIMALS;
}
