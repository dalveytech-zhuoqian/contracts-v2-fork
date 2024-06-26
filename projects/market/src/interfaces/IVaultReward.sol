//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

interface IVaultReward {
    function updateRewards() external;

    function updateRewardsByAccount(address) external;

    function setMarket(address market, address vault) external;

    function initialize(
        address _coreVault,
        address _vaultRouter,
        address _feeRouter
    ) external;

    function buy(
        IERC4626 vault,
        address to,
        uint256 amount,
        uint256 minSharesOut
    ) external returns (uint256); // move

    function sell(
        IERC4626 vault,
        address to,
        uint256 amount,
        uint256 minAssetsOut
    ) external returns (uint256); // move

    function calimLPReward() external;

    function getAPR() external returns (uint256);

    function getUSDBalance() external view returns (uint256); // move

    function getAUM() external returns (uint256);

    function getLPReward() external returns (uint256);

    function pendingRewards() external returns (uint256);

    function getLPPrice() external returns (uint256); // move

    function priceDecimals() external returns (uint256);

    function buyLpFee() external view returns (uint256);

    function sellLpFee() external view returns (uint256);
}
