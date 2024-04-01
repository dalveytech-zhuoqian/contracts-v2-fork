// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardDistributorFactory {
    struct Parameters {
        address rewardToken;
        address auth;
    }

    function deploy(Parameters calldata p) external returns (address proxy);

    function parameters() external returns (Parameters memory);
}
