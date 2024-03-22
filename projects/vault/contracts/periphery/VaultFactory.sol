// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVault} from "../interfaces/IVault.sol";
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract VaultFactory is IVaultFactory, UpgradeableBeacon {
    Parameters internal _parameters;

    event NewVault(address indexed vault, address indexed asset, address indexed market, string name, string symbol);

    constructor(address implementation_) UpgradeableBeacon(implementation_, msg.sender) {}

    function parameters() external view override returns (Parameters memory) {
        return _parameters;
    }

    function deploy(Parameters calldata p) external onlyOwner returns (address proxy) {
        _parameters = p;
        BeaconProxy beaconProxy = new BeaconProxy{salt: keccak256(abi.encode(
            p.name, 
            p.symbol, 
            block.timestamp
            ))}(address(this), bytes(""));
        proxy = address(beaconProxy);
        IVault(proxy).initialize();
        delete _parameters;
        emit NewVault(proxy, p.asset, p.market, p.name, p.symbol);
    }
}
