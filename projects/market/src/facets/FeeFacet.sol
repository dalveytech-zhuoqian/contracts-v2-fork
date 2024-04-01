// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FeeHandler} from "../lib/fee/FeeHandler.sol";
import {BalanceHandler} from "../lib/balance/BalanceHandler.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract FeeFacet is IAccessManaged {
    // uint256 public constant FEE_RATE_PRECISION = LibFundFee.PRECISION;

    //================================================
    // Fee Router外部函数
    //================================================
    function feeWithdraw(uint16 market, address to, uint256 amount) external restricted {
        // TODO
        address token = MarketHandler.Storage().token[market];
        BalanceHandler.feeToReward(token, market, to, amount);
    }

    function setFeeAndRates(uint16 market, uint8 feeType, uint256 feeAndRate) external restricted {
        // TODO
        FeeHandler.Storage().feeAndRates[market][feeType] = feeAndRate;
    }

    //================================================
    // fundfee外部函数
    //================================================
    function updateCumulativeFundingRate(uint16 market, uint256 longSize, uint256 shortSize) external onlySelf {
        // TODO too much to do
    }

    function setFundingRates(uint16 market, bool isLong, int256 fundingRate, int256 cumulativeFundingRate)
        external
        restricted
    {
        FeeHandler.Storage().fundingRates[market][isLong] = fundingRate;
        FeeHandler.Storage().cumulativeFundingRates[market][isLong] = cumulativeFundingRate;
    }

    function setFundingIntervals(uint16 market, uint256 interval) external restricted {
        FeeHandler.Storage().fundingIntervals[market] = interval;
    }

    function setConfigs(uint16 market, uint8 configType, uint256 value) external restricted {
        FeeHandler.Storage().configs[market][configType] = value;
    }

    function setCalIntervals(uint16 market, uint256 interval) external restricted {
        FeeHandler.Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(uint16 market, uint256 lastCalTime) external restricted {
        FeeHandler.Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(uint16 market, bool isLong, int256 calFundingRate) external restricted {
        FeeHandler.Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(uint16 market, uint256 loss) external restricted {
        FeeHandler.Storage().fundFeeLoss[market] = loss;
    }

    function addSkipTime(uint16 market, uint256 start, uint256 end) external restricted {
        // FeeHandler.addSkipTime(market, start, end);
    }

    //================================================
    // fee router 通用函数
    //================================================
    function initFeeFacet(uint16 market) external onlySelfOrRestricted {
        FeeHandler.initialize(market);
    }

    function collectFees(bytes calldata _data) external onlySelfOrRestricted {
        (address account, address token, int256[] memory fees, uint256 fundfeeLoss, uint16 market) =
            abi.decode(_data, (address, address, int256[], uint256, uint16));
        FeeHandler.collectFees(market, account, token, fees, fundfeeLoss);
    }

    function getExecFee(uint16 market) external view returns (uint256) {
        return FeeHandler.getExecFee(market);
    }

    function getFundingRate(uint16 market, bool isLong) internal view returns (int256) {
        return FeeHandler.getFundingRate(market, isLong);
    }

    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256) {
        return FeeHandler.Storage().cumulativeFundingRates[market][isLong];
    }

    function getNextFundingRate(address market, uint256 longSize, uint256 shortSize) public {
        //todo
    }

    function getFundingFee(address market, uint256 size, int256 entryFundingRate, bool isLong)
        external
        view
        returns (int256)
    {
        return FeeHandler.getFundingFee(market, size, entryFundingRate, isLong);
    }

    function getGlobalOpenInterest() public view returns (uint256 _globalSize) {
        //todo
    }
}
