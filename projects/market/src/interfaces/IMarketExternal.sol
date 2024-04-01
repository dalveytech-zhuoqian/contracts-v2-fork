// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarketExternal {
    function collectFees(bytes calldata _data) external;
    function getGlobalPnl(address vault) external view returns (int256);
}
