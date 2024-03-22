// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVaultReward} from "../interfaces/IVaultReward.sol";
import {IVaultRewardFactory} from "../interfaces/IVaultRewardFactory.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract VaultFactory is IVaultRewardFactory, UpgradeableBeacon {
    Parameters internal _parameters;

    event NewVaultReward(address indexed proxy, Parameters param);

    constructor(address implementation_) UpgradeableBeacon(implementation_, msg.sender) {}

    function parameters() external view override returns (Parameters memory) {
        return _parameters;
    }

    function deploy(Parameters calldata p) external onlyOwner returns (address proxy) {
        _parameters = p;
        BeaconProxy beaconProxy = new BeaconProxy{salt: keccak256(abi.encode(
            p.vault, 
            block.timestamp
            ))}(address(this), bytes(""));
        proxy = address(beaconProxy);
        IVaultReward(proxy).initialize();
        delete _parameters;
        emit NewVaultReward(proxy, p);
    }
}
