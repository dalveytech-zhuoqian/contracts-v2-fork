// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {
    IERC4626,
    ERC4626Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IMarket} from "../interfaces/IMarket.sol";
import {IVaultReward} from "../interfaces/IVaultReward.sol";
import {IVault} from "../interfaces/IVault.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Precision} from "../lib/utils/Precision.sol";
import {TransferHelper} from "../lib/utils/TransferHelper.sol";

contract Vault is ERC4626Upgradeable, AccessManagedUpgradeable, IVault {
    using SafeERC20 for IERC20;

    uint256 public constant NUMBER_OF_DEAD_SHARES = 1000;
    uint256 public constant FEE_RATE_PRECISION = Precision.FEE_RATE_PRECISION;
    bytes32 constant POS_STORAGE_POSITION = keccak256("blex.vault.storage");

    struct StorageStruct {
        bool allowBuy;
        bool isFreezeAccouting;
        bool isFreezeTransfer;
        address market;
        address vaultReward;
        uint256 cooldownDuration;
        uint256 buyLpFee;
        // 2%
        uint256 sellLpFee; // 1%
        uint256 totalFundsUsed;
        mapping(address => uint256) lastDepositAt;
        mapping(uint16 market => uint256) fundsUsed;
    }

    function _getStorage() private pure returns (StorageStruct storage $) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            $.slot := position
        }
    }

    event FreezeAccountingUpdated(bool isFreeze);
    event FreezeTransferUpdated(bool isFreeze);
    event AllowBuyUpdated(bool allow);
    event CoolDownDurationUpdated(uint256 duration);
    event LPFeeUpdated(bool isBuy, uint256 fee);
    event FundsUsedUpdated(uint16 indexed market, uint256 amount, uint256 totalFundsUsed);
    event MarketUpdated(address market);
    event DepositAsset(address indexed sender, address indexed owner, uint256 assets, uint256 shares, uint256 fee);
    event WithdrawAsset(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares,
        uint256 fee
    );

    modifier onlyMarket() {
        require(msg.sender == _getStorage().market);
        _;
    }

    function initialize(address _asset, string memory _name, string memory _symbol, address _market, address _authority)
        external
        onlyInitializing
    {
        super.__AccessManaged_init(_authority);
        super.__ERC20_init(_name, _symbol);
        super.__ERC4626_init(IERC20(_asset));

        StorageStruct storage $ = _getStorage();
        $.market = _market;
        $.cooldownDuration = 15 minutes; // 15
        $.sellLpFee = (1 * FEE_RATE_PRECISION) / 100; // 1%
    }

    function setIsFreezeAccounting(bool f) external restricted {
        StorageStruct storage $ = _getStorage();
        $.isFreezeAccouting = f;
        emit FreezeAccountingUpdated(f);
    }

    function setIsFreezeTransfer(bool f) external restricted {
        StorageStruct storage $ = _getStorage();
        $.isFreezeTransfer = f;
        emit FreezeTransferUpdated(f);
    }

    function setAllowBuy(bool allow) external restricted {
        StorageStruct storage $ = _getStorage();
        $.allowBuy = allow;
        emit AllowBuyUpdated(allow);
    }

    function setMarket(address _m) external override restricted {
        StorageStruct storage $ = _getStorage();
        $.market = _m;
        emit MarketUpdated(_m);
    }

    function setLpFee(bool isBuy, uint256 fee) external restricted {
        StorageStruct storage $ = _getStorage();
        isBuy ? $.buyLpFee = fee : $.sellLpFee = fee;
        emit LPFeeUpdated(isBuy, fee);
    }

    function setCooldownDuration(uint256 _duration) external restricted {
        StorageStruct storage $ = _getStorage();
        $.cooldownDuration = _duration;
        emit CoolDownDurationUpdated(_duration);
    }

    function withdrawFromVault(address to, uint256 amount) external override onlyMarket {
        StorageStruct storage $ = _getStorage();
        require(false == $.isFreezeTransfer, "VaultRouter:freeze");
        SafeERC20.safeTransfer(IERC20(asset()), to, amount);
    }

    function borrowFromVault(uint16 market, uint256 amount) external override onlyMarket {
        StorageStruct storage $ = _getStorage();
        require(false == $.isFreezeAccouting, "VaultRouter:freeze");
        _updateFundsUsed(market, amount, true);
    }

    function repayToVault(uint16 market, uint256 amount) external override onlyMarket {
        StorageStruct storage $ = _getStorage();
        require(false == $.isFreezeAccouting, "VaultRouter:freeze");
        _updateFundsUsed(market, amount, false);
    }
    //================================================================================================
    //     view functions
    //================================================================================================

    function priceDecimals() external pure override returns (uint256) {
        return 8;
    }

    function fundsUsed(uint16 market) external view returns (uint256) {
        return _getStorage().fundsUsed[market];
    }

    function totalAssets() public view virtual override(ERC4626Upgradeable, IERC4626) returns (uint256) {
        return getAUM();
    }

    function getLPFee(bool isBuy) public view returns (uint256) {
        StorageStruct storage $ = _getStorage();
        return isBuy ? $.buyLpFee : $.sellLpFee;
    }

    function getUSDBalance() public view returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    function getAUM() public view override returns (uint256) {
        StorageStruct storage $ = _getStorage();
        int256 unbalancedPnl = IMarket($.market).getGlobalPnl(address(this));
        uint256 usdBalance = getUSDBalance();

        uint256 aum;
        if (unbalancedPnl > 0) {
            aum = usdBalance - uint256(unbalancedPnl);
        } else {
            aum = usdBalance + uint256(-unbalancedPnl);
        }
        return aum;
    }

    function sellLpFee() external view override returns (uint256) {
        return _getStorage().sellLpFee;
    }

    function buyLpFee() external view override returns (uint256) {
        return _getStorage().buyLpFee;
    }

    //================================================================================================
    //     private functions
    //================================================================================================

    function _updateFundsUsed(uint16 market, uint256 amount, bool isBorrow) private {
        StorageStruct storage $ = _getStorage();
        if (isBorrow) {
            uint256 pendingFundsUsed = $.totalFundsUsed + amount;
            // uint256 aum = getAUM();
            // require(aum > 0, "VaultRouter:!aum");
            // 2023/7/27 painter
            // require(pendingFundsUsed < aum, "VaultRouter:size>aum");

            $.fundsUsed[market] += amount;
            $.totalFundsUsed = pendingFundsUsed;
        } else {
            $.fundsUsed[market] -= amount;
            $.totalFundsUsed -= amount;
        }
        emit FundsUsedUpdated(market, $.fundsUsed[market], $.totalFundsUsed);
    }

    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view override returns (uint256 shares) {
        StorageStruct storage $ = _getStorage();
        shares = super._convertToShares(assets, rounding);
        bool isBuy = rounding == Math.Rounding.Floor;
        if (isBuy) return shares - computationalCosts(isBuy, shares);
        else return (shares * FEE_RATE_PRECISION) / (FEE_RATE_PRECISION - $.sellLpFee);
    }

    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view override returns (uint256 assets) {
        StorageStruct storage $ = _getStorage();
        assets = super._convertToAssets(shares, rounding);
        bool isBuy = rounding == Math.Rounding.Ceil;
        if (isBuy) {
            return (assets * FEE_RATE_PRECISION) / (FEE_RATE_PRECISION - $.buyLpFee);
        } else {
            return assets - computationalCosts(isBuy, assets);
        }
    }

    function _transFeeTofeeVault(
        address account,
        address _asset,
        uint256 fee, // assets decimals
        bool isBuy
    ) private {
        StorageStruct storage $ = _getStorage();
        if (fee == 0) return;

        uint8 kind = (isBuy ? 5 : 6);
        int256[] memory fees = new int256[](kind + 1);
        IERC20(_asset).approve(address($.market), fee);
        fees[kind] = int256(TransferHelper.parseVaultAsset(fee, IERC20Metadata(_asset).decimals()));
        IMarket($.market).collectFees(abi.encode(account, _asset, fees));
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal override {
        StorageStruct storage $ = _getStorage();
        require($.allowBuy, "buy is not allowed");
        require(false == $.isFreezeTransfer, "vault:freeze");
        $.lastDepositAt[receiver] = block.timestamp;
        uint256 s_assets = super._convertToAssets(shares, Math.Rounding.Ceil);
        uint256 cost = assets > s_assets ? assets - s_assets : s_assets - assets;
        uint256 _assets = assets > s_assets ? assets : s_assets;

        if (totalSupply() == 0) {
            _mint(address(0), NUMBER_OF_DEAD_SHARES);
            shares -= NUMBER_OF_DEAD_SHARES;
        }
        super._deposit(caller, receiver, _assets, shares);
        _transFeeTofeeVault(receiver, address(asset()), cost, true);

        emit DepositAsset(caller, receiver, assets, shares, cost);
    }

    function _withdraw(address caller, address receiver, address _owner, uint256 assets, uint256 shares)
        internal
        override
    {
        StorageStruct storage $ = _getStorage();
        require(false == $.isFreezeTransfer, "vault:freeze");
        require(block.timestamp > $.cooldownDuration + $.lastDepositAt[_owner], "vault:cooldown");
        uint256 s_assets = super._convertToAssets(shares, Math.Rounding.Floor);
        bool exceeds_assets = s_assets > assets;

        uint256 _assets = exceeds_assets ? assets : s_assets;

        // withdraw assets to user(after fee)
        super._withdraw(
            caller,
            receiver,
            _owner, // receiver
            _assets,
            shares
        );

        uint256 cost = exceeds_assets ? s_assets - assets : assets - s_assets;

        _transFeeTofeeVault(_owner, address(asset()), cost, false); //ok!

        emit WithdrawAsset(caller, receiver, _owner, assets, shares, cost);
    }

    function _update(address from, address to, uint256 value) internal override {
        _beforeTokenTransfer(from, to);
        super._update(from, to, value);
    }

    function _beforeTokenTransfer(address from, address to) internal {
        StorageStruct storage $ = _getStorage();
        if (from == address(0)) {
            IVaultReward($.vaultReward).updateRewardsByAccount(to);
        }
        if (to == address(0)) {
            IVaultReward($.vaultReward).updateRewardsByAccount(from);
        }
        if (from == address(0) || to == address(0)) return;
        revert("transfer not allowed");
    }

    function computationalCosts(bool isBuy, uint256 amount) public view override returns (uint256) {
        StorageStruct storage $ = _getStorage();
        if (isBuy) {
            return (amount * ($.buyLpFee)) / FEE_RATE_PRECISION;
        } else {
            return (amount * ($.sellLpFee)) / FEE_RATE_PRECISION;
        }
    }
}
