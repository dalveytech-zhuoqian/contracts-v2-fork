// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
//================================================================
//handlers
import {FeeHandler} from "../lib/fee/FeeHandler.sol";
import {BalanceHandler} from "../lib/balance/BalanceHandler.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
//================================================================
//interfaces
import {IVault} from "../interfaces/IVault.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {IFeeFacet} from "../interfaces/IFeeFacet.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//================================================================
//data types
import "../lib/types/Types.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract FeeFacet is IAccessManaged, IFeeFacet, UsingDiamondOwner {
    using EnumerableSet for EnumerableSet.UintSet;

    // //================================================================
    // // only self
    // //================================================================

    function SELF_collectFees(bytes calldata _data) external onlySelf {
        (
            address account,
            address token,
            int256[] memory fees,
            uint256 fundfeeLoss,
            uint16 market
        ) = abi.decode(_data, (address, address, int256[], uint256, uint16));
        uint256 _amount = IERC20(token).allowance(msg.sender, address(this));
        // todo 会存在这种现象嘛 如果存在要不要更新event
        //if (_amount == 0 && fundfeeLoss == 0) return;
        if (_amount != 0) {
            BalanceHandler.marketToFee(market, account, _amount, _data);
        }
        if (fundfeeLoss > 0) {
            uint256 _before = FeeHandler.Storage().fundFeeLoss[market];
            FeeHandler.Storage().fundFeeLoss[market] += fundfeeLoss;
            BalanceHandler.feeToMarket(market, account, fundfeeLoss, fees);
            // emit AddNegativeFeeLoss(market, account, _before, Storage().fundFeeLoss[market]);
        }
        emit FeeHandler.UpdateFee(account, market, fees, _amount);
    }

    function SELF_addFee(uint16 market, bytes calldata fee) external {
        if (address(this) != msg.sender) {
            _checkCanCall(msg.sender, msg.data);
        }
        (
            uint256 maxFRatePerDay,
            uint256 fRateFactor,
            uint256 mintFRate,
            uint256 minFundingInterval,
            uint256 fundingFeeLossOffLimit
        ) = abi.decode(fee, (uint256, uint256, uint256, uint256, uint256));
        FeeHandler.Storage().configs[market][
            uint8(FeeHandler.ConfigType.MaxFRatePerDay)
        ] = maxFRatePerDay;
        FeeHandler.Storage().configs[market][
            uint8(FeeHandler.ConfigType.FRateFactor)
        ] = fRateFactor;
        FeeHandler.Storage().configs[market][
            uint8(FeeHandler.ConfigType.MinFRate)
        ] = mintFRate;
        FeeHandler.Storage().configs[market][
            uint8(FeeHandler.ConfigType.MinFundingInterval)
        ] = minFundingInterval;
        FeeHandler.Storage().configs[market][
            uint8(FeeHandler.ConfigType.FundingFeeLossOffLimit)
        ] = fundingFeeLossOffLimit;
    }

    function SELF_updateCumulativeFundingRate(
        uint16 market,
        uint256 longSize,
        uint256 shortSize
    ) external override onlySelf {
        // TODO too much to do
    }
    // //================================================================
    // // ADMIN
    // //================================================================

    function initFeeFacet(uint16 market) external onlyOwner {
        FeeHandler.initialize(market);
    }

    function feeWithdraw(
        uint16 market,
        address to,
        uint256 amount
    ) external restricted {
        // TODO
        address token = MarketHandler.Storage().token[market];
        BalanceHandler.feeToReward(token, market, to, amount);
    }

    function setFeeAndRates(
        uint16 market,
        uint8 feeType,
        uint256 feeAndRate
    ) external restricted {
        // TODO
        FeeHandler.Storage().feeAndRates[market][feeType] = feeAndRate;
    }

    function setFundingRates(
        uint16 market,
        bool isLong,
        int256 fundingRate,
        int256 cumulativeFundingRate
    ) external restricted {
        FeeHandler.Storage().fundingRates[market][isLong] = fundingRate;
        FeeHandler.Storage().cumulativeFundingRates[market][
            isLong
        ] = cumulativeFundingRate;
    }

    function setFundingIntervals(
        uint16 market,
        uint256 interval
    ) external restricted {
        FeeHandler.Storage().fundingIntervals[market] = interval;
    }

    function setFeeConfigs(
        uint16 market,
        uint8 configType,
        uint256 value
    ) external restricted {
        FeeHandler.Storage().configs[market][configType] = value;
    }

    function setCalIntervals(
        uint16 market,
        uint256 interval
    ) external restricted {
        FeeHandler.Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(
        uint16 market,
        uint256 lastCalTime
    ) external restricted {
        FeeHandler.Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(
        uint16 market,
        bool isLong,
        int256 calFundingRate
    ) external restricted {
        FeeHandler.Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(uint16 market, uint256 loss) external restricted {
        FeeHandler.Storage().fundFeeLoss[market] = loss;
    }

    function addSkipTime(
        uint16 market,
        uint256 start,
        uint256 end
    ) external restricted {
        // FeeHandler.addSkipTime(market, start, end);
    }

    // //================================================
    // // view functions
    // //================================================
    function getOrderFees(
        MarketCache calldata data
    ) external view override returns (int256 fees) {
        return FeeHandler.getOrderFees(data);
    }

    function getExecFee(uint16 market) external view returns (uint256) {
        return FeeHandler.getExecFee(market);
    }

    function getFeesReceivable(
        MarketCache calldata params,
        PositionProps calldata position
    ) external view override returns (int256[] memory fees, int256 totalFee) {
        fees = FeeHandler.getFeesReceivable(params, position);
        totalFee = FeeHandler.totalFees(fees);
    }

    function getFundingRate(
        uint16 market,
        bool isLong
    ) internal view returns (int256) {
        return FeeHandler.getFundingRate(market, isLong);
    }

    function cumulativeFundingRates(
        uint16 market,
        bool isLong
    ) external view override returns (int256) {
        return FeeHandler.Storage().cumulativeFundingRates[market][isLong];
    }

    function getNextFundingRate(
        address market,
        uint256 longSize,
        uint256 shortSize
    ) public {
        //todo
    }

    function getFundingFee(
        uint16 market,
        uint256 size,
        int256 entryFundingRate,
        bool isLong
    ) external view returns (int256) {
        return FeeHandler.getFundingFee(market, size, entryFundingRate, isLong);
    }

    function getGlobalOpenInterest(
        uint16 market
    ) public view returns (uint256 _globalSize) {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        uint256 openInterest = 0;
        EnumerableSet.UintSet storage marketIds = $.marketIds[address(0)];
        address vault = $.vault[market];
        for (uint256 i = 0; i < marketIds.length(); i++) {
            uint16 marketId = uint16(marketIds.at(i));
            openInterest += IVault(vault).fundsUsed(marketId);
        }
        return openInterest;
    }

    function getFeeAndRatesOfMarket(
        uint16 market
    )
        external
        view
        override
        returns (
            uint256[] memory fees,
            int256[] memory fundingRates,
            int256[] memory _cumulativeFundingRates
        )
    {
        //todo merge with getfees?
        fees = new uint256[](uint8(FeeType.Counter));
        for (uint8 i = 0; i < uint8(FeeType.Counter); i++) {
            fees[i] = FeeHandler.Storage().feeAndRates[market][i];
        }
        fundingRates = new int256[](2);
        fundingRates[0] = FeeHandler.Storage().fundingRates[market][true];
        fundingRates[1] = FeeHandler.Storage().fundingRates[market][false];
        _cumulativeFundingRates = new int256[](2);
        _cumulativeFundingRates[0] = FeeHandler
            .Storage()
            .cumulativeFundingRates[market][true];
        _cumulativeFundingRates[1] = FeeHandler
            .Storage()
            .cumulativeFundingRates[market][false];
    }
}
