// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

interface IVault is IERC4626 {
    function initialize() external;

    function setMarket(address market) external;

    function withdrawFromVault(address to, uint256 amount) external; //transferToVault

    function borrowFromVault(uint16 market, uint256 amount) external;

    function repayToVault(uint16 market, uint256 amount) external;

    //=======================view==============

    function sellLpFee() external view returns (uint256);

    function buyLpFee() external view returns (uint256);

    function computationalCosts(bool isBuy, uint256 amount) external view returns (uint256);

    function getLPFee(bool isBuy) external view returns (uint256);

    function getUSDBalance() external view returns (uint256);

    function getAUM() external view returns (uint256);

    function fundsUsed(uint16 market) external view returns (uint256);

    function priceDecimals() external pure returns (uint256);

    function getLPPrice() external view returns (uint256);
}
