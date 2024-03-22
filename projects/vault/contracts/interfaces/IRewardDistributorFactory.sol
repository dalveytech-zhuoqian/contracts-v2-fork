// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardDistributorFactory {
    struct Parameters {
        address rewardToken;
        address rewardTracker;
        address auth;
    }

    function parameters() external returns (Parameters memory);
}
