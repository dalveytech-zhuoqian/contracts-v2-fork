// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPrice {
    function getPrice(
        address _token,
        bool _maximise
    ) external view returns (uint256);

    function fastPriceFeed() external view returns (address);
}
