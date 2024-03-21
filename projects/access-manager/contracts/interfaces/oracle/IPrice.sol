// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IPrice {
    function fastPriceFeed() external view returns (address);

    function chainPriceFeed() external view returns (address);

    function getPrice(
        address _token,
        bool _maximise
    ) external view returns (uint256);
}
