// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IVault is IERC4626 {
    function setVaultRouter(address vaultRouter) external;

    function setLpFee(bool isBuy, uint256 fee) external;

    function sellLpFee() external view returns (uint256);

    function buyLpFee() external view returns (uint256);

    function setCooldownDuration(uint256 duration) external;

    function computationalCosts(bool isBuy, uint256 amount) external view returns (uint256);

    function transferOutAssets(address to, uint256 amount) external;

    function getLPFee(bool isBuy) external view returns (uint256);

    function getUSDBalance() external view returns (uint256);

    function getAUM() external view returns (uint256);

    function priceDecimals() external pure returns (uint256);

    function fundsUsed(uint16 market) external view returns (uint256);
}
