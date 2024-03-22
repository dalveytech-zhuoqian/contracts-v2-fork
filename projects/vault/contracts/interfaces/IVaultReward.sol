//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVaultReward {
    function buy(address to, uint256 amount, uint256 minSharesOut) external returns (uint256); // move

    function sell(address to, uint256 amount, uint256 minAssetsOut) external returns (uint256); // move

    function claimLPReward() external;

    function updateRewards() external;

    function updateRewardsByAccount(address) external;

    function getAPR() external view returns (uint256);

    function pendingRewards() external view returns (uint256);

    function claimable(address) external view returns (uint256);

    function getLPReward(address _account) public view override returns (uint256);
}
