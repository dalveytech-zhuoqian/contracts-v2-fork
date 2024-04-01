// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVaultFactory {
    struct Parameters {
        address asset;
        address market;
        string name;
        string symbol;
        address auth;
    }

    function parameters() external returns (Parameters memory);
    function deploy(Parameters calldata p) external returns (address proxy);
}
