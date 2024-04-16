// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPrice {
    function getPrice(
        uint16 market,
        bool _maximise
    ) external view returns (uint256);
    function priceFeed(uint16 market) external view returns (address);
    function usdtFeed() external view returns (address);
}
