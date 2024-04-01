// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVault} from "../interfaces/IVault.sol";
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

contract VaultFactory is IVaultFactory, AccessManagedUpgradeable {
    Parameters internal _parameters;
    address public beacon;

    event NewVault(address indexed vault, address indexed asset, address indexed market, string name, string symbol);

    function initialize(address _beacon, address _auth) external initializer {
        beacon = _beacon;
        __AccessManaged_init(_auth);
    }

    function parameters() external view override returns (Parameters memory) {
        return _parameters;
    }

    function deploy(Parameters calldata p) external restricted returns (address proxy) {
        _parameters = p;
        BeaconProxy beaconProxy = new BeaconProxy{salt: keccak256(abi.encode(
            p.name, 
            p.symbol, 
            block.timestamp
            ))}(beacon, bytes(""));
        proxy = address(beaconProxy);
        IVault(proxy).initialize();
        delete _parameters;
        emit NewVault(proxy, p.asset, p.market, p.name, p.symbol);
    }
}
