//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IRewardDistributor {
    function initialize() external;

    function pendingRewards() external view returns (uint256);

    function distribute() external returns (uint256);

    function tokensPerInterval() external view returns (uint256);

    function setRewardTracker(address _rewardTracker) external;
}
