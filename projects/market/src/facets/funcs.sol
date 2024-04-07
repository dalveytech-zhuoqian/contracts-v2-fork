// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IVault} from "../interfaces/IVault.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

uint8 constant usdDecimals = 18; //数量精度

function vault(uint16 market) view returns (IVault) {
    return IVault(MarketHandler.vault(market));
}

function formatCollateral(uint256 amount, address colleteralToken) view returns (uint256) {
    uint8 collateralTokenDigits = IERC20Metadata(colleteralToken).decimals();
    return (amount * (10 ** uint256(collateralTokenDigits))) / (10 ** usdDecimals);
}

function transferOut(address tokenAddress, address _to, uint256 _tokenAmount) {
    // If the token amount is 0, return.
    if (_tokenAmount == 0) return;
    // Format the collateral amount based on the token's decimals.
    _tokenAmount = formatCollateral(_tokenAmount, tokenAddress);
    // Transfer the tokens to the specified address.
    SafeERC20.safeTransfer(IERC20Metadata(tokenAddress), _to, _tokenAmount);
}
