// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Vault} from "../vault/Vault.sol";

contract VaultFactory is AccessManagedUpgradeable {
    struct Parameters {
        address asset;
        string name;
        string symbol;
        address market;
    }

    Parameters public parameters;
    uint256 public vaultCount;
    address[] public vaults;

    event NewVault(address indexed vault, address indexed asset, address indexed market, string name, string symbol);

    function initialize(address _auth) external initializer {
        super.__AccessManaged_init(_auth);
    }

    /// @notice Deploy proxy for cake pool
    /// @param _user: Cake pool user
    /// @return proxy The proxy address
    function deploy(Parameters calldata p) external restricted returns (address proxy) {
        // TODO
        // 1. 做到可升级
        // 2. 一个升级, 全部升级
        parameters = p;
        vault = new Vault{salt: keccak256(abi.encode(
            p.name, 
            p.symbol, 
            block.timestamp
            ))}();
        vault.initialize(p.asset, p.market, p.name, p.symbol, authority());
        delete parameters;
        emit NewVault(address(vault), p.asset, p.market, p.name, p.symbol);
    }

    function upgradeTo(address _implementation) external restricted {
        for (uint256 i = 0; i < vaultCount; i++) {
            Vault vault = Vault(vaults[i]);
            // vault.upgradeTo(_implementation);
        }
    }
}
