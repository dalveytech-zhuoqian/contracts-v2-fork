// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

library TransferHelper {
    uint8 public constant usdDecimals = 18; //数量精度

    /**
     * @dev Parses the vault asset amount by adjusting the number of decimal places.
     * @param amount The original asset amount in vault.
     * @param originDigits The number of decimal places for the original asset.
     * @return The parsed vault asset amount.
     */
    function parseVaultAsset(
        uint256 amount,
        uint8 originDigits
    ) internal pure returns (uint256) {
        return (amount * (10 ** uint256(usdDecimals))) / (10 ** originDigits);
    }
}
