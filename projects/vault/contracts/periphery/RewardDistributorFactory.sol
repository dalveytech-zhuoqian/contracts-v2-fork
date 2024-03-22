// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRewardDistributor} from "../interfaces/IRewardDistributor.sol";
import {IRewardDistributorFactory} from "../interfaces/IRewardDistributorFactory.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract RewardDistributorFactory is IRewardDistributorFactory, UpgradeableBeacon {
    Parameters internal _parameters;

    event NewRewardDistributor(address indexed proxy, Parameters param);

    constructor(address implementation_) UpgradeableBeacon(implementation_, msg.sender) {}

    function parameters() external view override returns (Parameters memory) {
        return _parameters;
    }

    function deploy(Parameters calldata p) external onlyOwner returns (address proxy) {
        _parameters = p;
        BeaconProxy beaconProxy = new BeaconProxy{salt: keccak256(abi.encode(
            p.rewardToken, 
            p.rewardTracker, 
            block.timestamp
            ))}(address(this), bytes(""));
        proxy = address(beaconProxy);
        IRewardDistributor(proxy).initialize();
        delete _parameters;
        emit NewRewardDistributor(proxy, p);
    }
}
