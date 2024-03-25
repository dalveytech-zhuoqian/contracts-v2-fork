// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import {IVaultRewardFactory} from "../interfaces/IVaultRewardFactory.sol";
import {IRewardDistributorFactory} from "../interfaces/IRewardDistributorFactory.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

contract VaultBuilder is AccessManagedUpgradeable {
    address public vaultFactory;
    address public vaultRewardFactory;
    address public rewardDistributorFactory;

    event NewFactory(address vaultFactory, address vaultRewardFactory, address rewardDistributorFactory);

    event NewBuild(address indexed vault, address indexed vaultReward, address indexed vaultRewardDistributor);

    function initialize(
        address _vaultFactory,
        address _vaultRewardFactory,
        address _rewardDistributorFactory,
        address _auth
    ) external initializer {
        __AccessManaged_init(_auth);
        vaultFactory = _vaultFactory;
        vaultRewardFactory = _vaultRewardFactory;
        rewardDistributorFactory = _rewardDistributorFactory;
        emit NewFactory(_vaultFactory, _vaultRewardFactory, _rewardDistributorFactory);
    }

    function deploy(
        IVaultFactory.Parameters calldata vfp,
        IVaultRewardFactory.Parameters calldata rfp,
        IRewardDistributorFactory.Parameters calldata rdp
    ) external restricted {
        address vault = IVaultFactory(vaultFactory).deploy(vfp);
        address vaultReward = IVaultRewardFactory(vaultRewardFactory).deploy(rfp);
        address vaultRewardDistributor = IRewardDistributorFactory(rewardDistributorFactory).deploy(rdp);
        emit NewBuild(vault, vaultReward, vaultRewardDistributor);
    }
}
