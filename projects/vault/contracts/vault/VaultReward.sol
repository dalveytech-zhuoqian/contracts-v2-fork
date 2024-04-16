// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRewardDistributor} from "../interfaces/IRewardDistributor.sol";
import {IMarket} from "../interfaces/IMarket.sol";
import {IVault, IERC4626} from "../interfaces/IVault.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SafeMath} from "../lib/SafeMath.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVaultReward} from "../interfaces/IVaultReward.sol";
import {IVaultRewardFactory} from "../interfaces/IVaultRewardFactory.sol";

contract VaultReward is
    AccessManagedUpgradeable,
    ReentrancyGuardUpgradeable,
    IVaultReward
{
    using SafeCast for int256;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public constant PRECISION = 1e30;
    bytes32 constant POS_STORAGE_POSITION =
        keccak256("blex.vault.reward.storage");

    struct StorageStruct {
        IVault vault;
        IMarket market;
        address distributor;
        uint256 cumulativeRewardPerToken;
        uint256 apr;
        mapping(address => uint256) previousCumulatedRewardPerToken;
        mapping(address => uint256) lpEarnedRewards;
        mapping(address => uint256) claimableReward;
        mapping(address => uint256) averageStakedAmounts;
    }

    function _getStorage() internal pure returns (StorageStruct storage $) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            $.slot := position
        }
    }

    event LogUpdatePool(uint256 supply, uint256 cumulativeRewardPerToken);
    event Harvest(address account, uint256 amount);

    function initialize() external override initializer {
        IVaultRewardFactory.Parameters memory p = IVaultRewardFactory(
            msg.sender
        ).parameters();

        require(p.vault != address(0));
        require(p.market != address(0));
        require(p.distributor != address(0));

        super.__AccessManaged_init(p.authority);
        super.__ReentrancyGuard_init();

        _getStorage().vault = IVault(p.vault);
        _getStorage().market = IMarket(p.market);
        _getStorage().distributor = p.distributor;
    }

    function setAPR(uint256 _apr) external restricted {
        _getStorage().apr = _apr;
    }
    /**
     * @dev This function is used to buy shares in a vault using an ERC20 asset as payment.
     * @param to The address where the purchased shares will be sent.
     * @param amount The amount of ERC20 tokens to use for purchasing the shares.
     * @param minSharesOut The minimum number of shares that the buyer expects to receive for their payment.
     * @return sharesOut The actual number of shares purchased by the buyer.
     */

    function buy(
        address to,
        uint256 amount,
        uint256 minSharesOut
    ) public override nonReentrant returns (uint256 sharesOut) {
        IVault vault = _getStorage().vault;
        address _token = vault.asset();
        SafeERC20.safeTransferFrom(
            IERC20(_token),
            msg.sender,
            address(this),
            amount
        );
        IERC20(_token).approve(address(vault), amount);
        if ((sharesOut = vault.deposit(amount, to)) < minSharesOut) {
            revert("MinSharesError");
        }
    }

    /**
     * @dev This function sells a specified amount of shares in a given vault on behalf of the caller using the `vaultReward` contract.
     * The `to` address receives the resulting assets of the sale.
     * @param to The address that receives the resulting shares of the sale.
     * @param shares The amount of shares to sell.
     * @param minAssetsOut The minimum amount of assets the caller expects to receive from the sale.
     * @return assetOut The resulting number of shares received by the `to` address.
     */
    function sell(
        address to,
        uint256 shares,
        uint256 minAssetsOut
    ) public override nonReentrant returns (uint256 assetOut) {
        IVault vault = _getStorage().vault;
        if ((assetOut = vault.redeem(shares, to, to)) < minAssetsOut) {
            revert("MinOutError");
        }
        if (vault.balanceOf(to) == 0) _claimLPRewardForAccount(to);
    }

    /**
     * @dev This function allows an LP (liquidity provider) to claim their rewards in the current market.
     * The function first checks that the LP has a non-zero balance in the vault contract.
     * If the LP has a non-zero balance, the function calls the `pendingRewards` function to calculate the amount of
     * rewards the LP is entitled to. The LP's earned rewards are then stored in the `lpEarnedRewards` mapping.
     * Finally, the `transferFromVault` function of the `vaultRouter` contract is called to transfer the rewards
     * from the market's vault to the LP's account.
     */
    function claimLPReward() public override nonReentrant {
        address _account = msg.sender;
        if (IVault(_getStorage().vault).balanceOf(_account) == 0) return;
        _claimLPRewardForAccount(msg.sender);
    }

    function _claimLPRewardForAccount(address _account) private {
        updateRewardsByAccount(_account);
        uint256 tokenAmount = _getStorage().claimableReward[_account];
        _getStorage().claimableReward[_account] = 0;
        IERC20(_getStorage().vault.asset()).safeTransfer(_account, tokenAmount);
        emit Harvest(_account, tokenAmount);
    }

    /**
     * @dev This function is used to update rewards.
     * @notice function can only be called without reentry.
     */
    function updateRewards() external nonReentrant {
        updateRewardsByAccount(address(0));
    }

    /**
     * @dev This function is used to update rewards.
     * @notice function can only be called without reentry.
     * @param _account needs to update the account address for rewards. If it is 0, the rewards for all accounts will be updated.
     */
    function updateRewardsByAccount(address _account) public override {
        uint256 blockReward = IRewardDistributor(_getStorage().distributor)
            .distribute(); //
        uint256 supply = _getStorage().vault.totalSupply();
        // LP
        uint256 _cumulativeRewardPerToken = _getStorage()
            .cumulativeRewardPerToken; //
        if (supply > 0 && blockReward > 0) {
            // ，
            _cumulativeRewardPerToken =
                _cumulativeRewardPerToken +
                (blockReward * PRECISION) /
                supply;
            // GLP = GLP + ERewards * Epoch/ GLP；
            _getStorage().cumulativeRewardPerToken = _cumulativeRewardPerToken; //
            emit LogUpdatePool(supply, _getStorage().cumulativeRewardPerToken);
        }

        // ，，
        if (_cumulativeRewardPerToken == 0) {
            return;
        }

        if (_account != address(0)) {
            // SumRewards = Sum（IRewards 1 : IRewards n）
            uint256 stakedAmount = stakedAmounts(_account); //
            uint256 accountReward = (stakedAmount *
                (_cumulativeRewardPerToken -
                    _getStorage().previousCumulatedRewardPerToken[_account])) /
                PRECISION; //
            uint256 _claimableReward = _getStorage().claimableReward[_account] +
                accountReward;

            _getStorage().claimableReward[_account] = _claimableReward; //
            _getStorage().previousCumulatedRewardPerToken[
                _account
            ] = _cumulativeRewardPerToken;
            //
            if (_claimableReward > 0 && stakedAmounts(_account) > 0) {
                uint256 nextCumulativeReward = _getStorage().lpEarnedRewards[
                    _account
                ] + accountReward;
                // ，
                _getStorage().averageStakedAmounts[_account] = _getStorage()
                    .averageStakedAmounts[_account]
                    .mul(_getStorage().lpEarnedRewards[_account])
                    .div(nextCumulativeReward)
                    .add(
                        stakedAmount.mul(accountReward).div(
                            nextCumulativeReward
                        )
                    );
                _getStorage().lpEarnedRewards[_account] = nextCumulativeReward; //
            }
        }
    }

    /**
     * @dev This function allows an LP (liquidity provider) to view the amount of rewards they have earned in the current market.
     * The function uses the `msg.sender` parameter to look up the earned rewards for the calling account in the `lpEarnedRewards` mapping.
     * The function returns the amount of rewards earned by the calling account as a `uint256`.
     * @return The amount of rewards earned by the calling account as a `uint256`.
     */
    function getLPReward(
        address _account
    ) public view override returns (uint256) {
        if (_getStorage().lpEarnedRewards[_account] == 0) return 0;
        // return lpEarnedRewards[msg.sender] - claimable(msg.sender);
        return
            _getStorage().lpEarnedRewards[_account] -
            _getStorage().claimableReward[_account];
    }

    function getAPR() external view override returns (uint256) {
        return _getStorage().apr;
    }

    /**
     * @dev This function is used to retrieve the number of reward tokens distributed per interval in a market.
     * The function calls the `tokensPerInterval` function of the `IRewardDistributor` contract, which returns the number of reward tokens distributed per interval as a `uint256`.
     * @return The number of reward tokens distributed per interval in the market as a `uint256`.
     */
    function tokensPerInterval() external view returns (uint256) {
        return
            IRewardDistributor(_getStorage().distributor).tokensPerInterval();
    }

    function pendingRewards() external view override returns (uint256) {
        return claimable(msg.sender);
    }

    /**
     * @dev This function is used to retrieve the amount of rewards claimable by a user in a market.
     * The function calculates the amount of claimable rewards by first retrieving the user's staked amount in the market from the `stakedAmounts` mapping.
     * If the user has no stake, the function returns the previously claimed reward amount stored in the `claimableReward` mapping.
     * Otherwise, the function retrieves the total supply of LP tokens in the market from the `vault` contract and the total pending rewards from the `IRewardDistributor` contract.
     * The pending rewards are then multiplied by the `PRECISION` constant and added to the `cumulativeRewardPerToken` variable to calculate the next cumulative reward per token value.
     * The difference between the new cumulative reward per token value and the previous one stored in the `previousCumulatedRewardPerToken` mapping for the user is multiplied by the user's staked amount and divided by the `PRECISION` constant to calculate the claimable reward amount.
     * Finally, the function returns the sum of the user's previously claimed reward amount and the newly calculated claimable reward amount.
     * @param _account The user's account address.
     * @return The amount of rewards claimable by the user in the market as a `uint256`.
     */
    function claimable(
        address _account
    ) public view override returns (uint256) {
        uint256 stakedAmount = stakedAmounts(_account);
        if (stakedAmount == 0) {
            return _getStorage().claimableReward[_account];
        }
        uint256 supply = _getStorage().vault.totalSupply();
        uint256 _pendingRewards = IRewardDistributor(_getStorage().distributor)
            .pendingRewards()
            .mul(PRECISION);
        uint256 nextCumulativeRewardPerToken = _getStorage()
            .cumulativeRewardPerToken
            .add(_pendingRewards.div(supply));
        return
            _getStorage().claimableReward[_account].add(
                stakedAmount
                    .mul(
                        nextCumulativeRewardPerToken.sub(
                            _getStorage().previousCumulatedRewardPerToken[
                                _account
                            ]
                        )
                    )
                    .div(PRECISION)
            );

        /* uint256 accountReward = (stakedAmount *
            (cumulativeRewardPerToken -
                previousCumulatedRewardPerToken[_account])) / PRECISION;
        return claimableReward[_account] + accountReward; */
    }

    function stakedAmounts(address _account) public view returns (uint256) {
        return _getStorage().vault.balanceOf(_account);
    }
}
