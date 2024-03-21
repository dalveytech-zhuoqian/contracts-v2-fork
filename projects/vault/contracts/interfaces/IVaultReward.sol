//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IVaultReward {
    function buy(address to, uint256 amount, uint256 minSharesOut) external returns (uint256); // move

    function sell(address to, uint256 amount, uint256 minAssetsOut) external returns (uint256); // move

    function claimLPReward() external;

    function updateRewards() external;

    function updateRewardsByAccount(address) external;

    function getAPR() external returns (uint256);

    function getLPReward() external returns (uint256);

    function pendingRewards() external returns (uint256);

    function getLPPrice() external returns (uint256);

    function priceDecimals() external returns (uint256);
}
