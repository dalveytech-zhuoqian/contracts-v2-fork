// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IMarket} from "../market/IMarket.sol";

interface IFastPriceFeed {
    function setPricesAndExecute(
        address token,
        uint256 price,
        uint256 timestamp,
        IMarket.OrderExec[] memory orders
    ) external;

    function lastUpdatedAtBlock(address name) external view returns (uint256);

    function setPrices(address[] memory _tokens, uint256[] memory _prices, uint256 _timestamp) external;

    function chainPriceFeed() external view returns (address);
}
