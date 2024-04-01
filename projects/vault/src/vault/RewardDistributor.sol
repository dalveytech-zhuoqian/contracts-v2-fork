// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

import {IVaultReward} from "../interfaces/IVaultReward.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRewardDistributorFactory} from "../interfaces/IRewardDistributorFactory.sol";
import {IRewardDistributor} from "../interfaces/IRewardDistributor.sol";

contract RewardDistributor is AccessManagedUpgradeable, IRewardDistributor {
    using SafeERC20 for IERC20;

    bytes32 constant POS_STORAGE_POSITION = keccak256("blex.reward.distributor.storage");

    struct StorageStruct {
        address rewardToken;
        uint256 tokensPerInterval;
        uint256 lastDistributionTime;
        address rewardTracker;
    }

    function _getStorage() private pure returns (StorageStruct storage $) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            $.slot := position
        }
    }

    event Distribute(uint256 amount);
    event TokensPerIntervalChange(uint256 amount);
    /**
     * @dev Modifier to only allow the reward tracker contract to call a function.
     */

    modifier onlyRewardTracker() {
        require(msg.sender == _getStorage().rewardTracker, "RewardDistributor: invalid msg.sender");
        _;
    }

    function setRewardTracker(address _rewardTracker) external {
        require(_getStorage().rewardTracker == address(0), "RewardDistributor: reward tracker already set");
        _getStorage().rewardTracker = _rewardTracker;
    }

    function initialize() external override initializer {
        IRewardDistributorFactory.Parameters memory p = IRewardDistributorFactory(msg.sender).parameters();
        require(p.rewardToken != address(0));
        require(p.auth != address(0));
        super.__AccessManaged_init(p.auth);
        _getStorage().rewardToken = p.rewardToken;
    }

    /**
     * @dev Withdraws tokens from the contract and transfers them to the specified account.
     * Only the admin can call this function.
     * @param _token The address of the token to withdraw.
     * @param _account The address to transfer the tokens to.
     * @param _amount The amount of tokens to withdraw.
     */
    function withdrawToken(address _token, address _account, uint256 _amount) external restricted {
        IERC20(_token).safeTransfer(_account, _amount);
    }

    /**
     * @dev Updates the last distribution time to the current block timestamp.
     * Only the admin can call this function.
     */
    function updateLastDistributionTime() external restricted {
        _getStorage().lastDistributionTime = block.timestamp;
    }

    /**
     * @dev Sets the number of tokens to distribute per interval.
     * Only the admin can call this function.
     * @param _amount The number of tokens per interval.
     */
    function setTokensPerInterval(uint256 _amount) external restricted {
        if (_getStorage().lastDistributionTime == 0) _getStorage().lastDistributionTime = block.timestamp;
        IVaultReward(_getStorage().rewardTracker).updateRewards();
        _getStorage().tokensPerInterval = _amount;
        emit TokensPerIntervalChange(_amount);
    }

    /**
     * @dev Called by `VaultReward`.Distributes pending rewards to the reward tracker contract.
     * Only the reward tracker contract can call this function.
     * @return The amount of rewards distributed.
     */
    function distribute() external onlyRewardTracker returns (uint256) {
        uint256 amount = pendingRewards();
        if (amount == 0) {
            return 0;
        }

        _getStorage().lastDistributionTime = block.timestamp;

        uint256 balance = IERC20(_getStorage().rewardToken).balanceOf(address(this));
        if (amount > balance) {
            amount = balance;
        }

        IERC20(_getStorage().rewardToken).safeTransfer(msg.sender, amount);

        emit Distribute(amount);
        return amount;
    }
    //====================================================================================
    //    view functions
    //====================================================================================

    /**
     * @dev Calculates the pending rewards based on the last distribution time and tokens per interval.
     * @return The pending rewards.
     */
    function pendingRewards() public view returns (uint256) {
        if (block.timestamp == _getStorage().lastDistributionTime) {
            return 0;
        }

        uint256 timeDiff = block.timestamp - _getStorage().lastDistributionTime;
        return _getStorage().tokensPerInterval * timeDiff;
    }

    function tokensPerInterval() external view override returns (uint256) {
        return _getStorage().tokensPerInterval;
    }
}
