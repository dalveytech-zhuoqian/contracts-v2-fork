// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarketInternal {
    /**
     * @dev Retrieves the number of decimal places for USD.
     * @return The number of decimal places for USD.
     */
    function getUSDDecimals() external pure returns (uint8);

    /**
     * @dev Parses the vault asset amount by adjusting the number of decimal places.
     * @param amount The original asset amount in vault.
     * @param originDigits The number of decimal places for the original asset.
     * @return The parsed vault asset amount.
     */
    function parseVaultAsset(uint256 amount, uint8 originDigits) external pure returns (uint256);

    /**
     * @dev This library contains utility functions for transferring assets.
     * @param amount The amount of assets to transfer in integer format with decimal precision.
     * @param collateralTokenDigits The decimal precision of the collateral token.
     * @return The transferred asset amount converted to integer with decimal precision for the USD stablecoin.
     * This function is internal and can only be accessed within the current contract or library.
     */
    function parseVaultAssetSigned(int256 amount, uint8 collateralTokenDigits) external pure returns (int256);
    /**
     * @dev Transfers a specified amount of tokens from a given address to another address.
     * @param tokenAddress The address of the token.
     * @param _from The address from which the tokens will be transferred.
     * @param _to The address to which the tokens will be transferred.
     * @param _tokenAmount The amount of tokens to be transferred.
     */
    function transferIn(address tokenAddress, address _from, address _to, uint256 _tokenAmount) external;
}
