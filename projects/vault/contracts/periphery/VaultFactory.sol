// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {Vault} from "../vault/Vault.sol";
import {IVaultFactory} from "../interfaces/IVaultFactory.sol";

contract VaultFactory is AccessManagedUpgradeable, IVaultFactory {
    Parameters internal _parameters;
    uint256 public vaultCount;
    address[] public vaults;

    event NewVault(address indexed vault, address indexed asset, address indexed market, string name, string symbol);

    function initialize(address _auth) external initializer {
        super.__AccessManaged_init(_auth);
    }

    function parameters() external view override returns (Parameters memory) {
        return _parameters;
    }

    /// @notice Deploy proxy for cake pool
    /// @return proxy The proxy address
    function deploy(Parameters calldata p) external restricted returns (address proxy) {
        // TODO
        // 1. 做到可升级
        // 2. 一个升级, 全部升级
        _parameters = p;
        Vault vault = new Vault{salt: keccak256(abi.encode(
            p.name, 
            p.symbol, 
            block.timestamp
            ))}();
        vault.initialize();
        delete _parameters;
        emit NewVault(address(vault), p.asset, p.market, p.name, p.symbol);
    }

    function upgradeTo(address _implementation) external restricted {
        for (uint256 i = 0; i < vaultCount; i++) {
            Vault vault = Vault(vaults[i]);
            // vault.upgradeTo(_implementation);
        }
    }
}
