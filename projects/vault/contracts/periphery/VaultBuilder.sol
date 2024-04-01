// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IVaultFactory} from "../interfaces/IVaultFactory.sol";
import {IVaultRewardFactory} from "../interfaces/IVaultRewardFactory.sol";
import {IRewardDistributorFactory} from "../interfaces/IRewardDistributorFactory.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {IRewardDistributor} from "../interfaces/IRewardDistributor.sol";

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

    struct Parameters {
        address asset;
        address market;
        string name;
        string symbol;
        address auth;
    }

    function deploy(Parameters calldata p) external restricted {
        address vault = IVaultFactory(vaultFactory).deploy(
            IVaultFactory.Parameters({asset: p.asset, market: p.market, name: p.name, symbol: p.symbol, auth: p.auth})
        );

        address vaultRewardDistributor = IRewardDistributorFactory(rewardDistributorFactory).deploy(
            IRewardDistributorFactory.Parameters({rewardToken: p.asset, auth: p.auth})
        );

        address vaultReward = IVaultRewardFactory(vaultRewardFactory).deploy(
            IVaultRewardFactory.Parameters({
                vault: vault,
                market: p.market,
                distributor: vaultRewardDistributor,
                authority: p.auth
            })
        );

        IRewardDistributor(vaultRewardDistributor).setRewardTracker(vaultReward);

        emit NewBuild(vault, vaultReward, vaultRewardDistributor);
    }
}
