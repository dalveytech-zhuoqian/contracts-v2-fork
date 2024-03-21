// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVaultReward} from "../interfaces/IVaultReward.sol";
import {IVault} from "../interfaces/IVault.sol";

contract VaultReader {
    string constant version = "0.0.1";
    IVault public vault;
    IVaultReward public vaultReward;

    constructor(address _vault, address _vaultReward) {
        vault = IVault(_vault);
        vaultReward = IVaultReward(_vaultReward);
    }

    struct Cache {
        address rewardToken;
        uint256 priceDecimals;
        uint256 stakedAmounts;
        uint256 price;
        uint256 sellFee;
        uint256 buyFee;
        uint256 pendingReward;
        uint256 apr;
        uint256 priceDecimal;
        uint256 usdBalance;
    }

    function info(address _account) external view returns (Cache memory c) {
        c.rewardToken = vault.asset();
        c.priceDecimals = vault.priceDecimals();
        c.stakedAmounts = vault.balanceOf(_account);
        c.price = vault.getLPPrice();
        c.sellFee = vault.sellLpFee();
        c.buyFee = vault.buyLpFee();
        c.pendingReward = vaultReward.claimable(_account);
        c.apr = vaultReward.getAPR();
        c.priceDecimal = vault.priceDecimals();
        c.usdBalance = vault.getUSDBalance();
    }
}
