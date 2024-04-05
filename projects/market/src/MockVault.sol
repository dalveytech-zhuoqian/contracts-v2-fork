// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IVault} from "./interfaces/IVault.sol";

contract MockVault {
    function borrowFromVault(uint16 market, uint256 amount) external {
        // do nothing
    }
    function withdrawFromVault(address to, uint256 amount) external {
        // transfer???
    }
    function repayToVault(uint16 market, uint256 amount) external {
        // do nothing
    }

    function sellLpFee() external view returns (uint256) {}

    function buyLpFee() external view returns (uint256) {}

    function computationalCosts(bool isBuy, uint256 amount) external view returns (uint256) {}

    function getLPFee(bool isBuy) external view returns (uint256) {}

    function getUSDBalance() external view returns (uint256) {}

    function getAUM() external view returns (uint256) {
        return 10000 * 10 ** 6;
    }

    function fundsUsed(uint16 market) external view returns (uint256) {}

    function priceDecimals() external pure returns (uint256) {
        return 8;
    }
}
