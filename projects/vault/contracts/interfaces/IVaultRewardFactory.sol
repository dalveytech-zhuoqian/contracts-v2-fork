// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVaultRewardFactory {
    struct Parameters {
        address vault;
        address market;
        address distributor;
        address authority;
    }

    function parameters() external returns (Parameters memory);
}
