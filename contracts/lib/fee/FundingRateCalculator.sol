// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {Calc} from "../utils/Calc.sol";

library FundingRateCalculator {
    using SafeCast for uint256;
    using SafeCast for int256;
    using FundingRateCalculator for FundFeeStorageMemory;
    using FundingRateCalculator for FundFeeVars;

    uint256 public constant MIN_FUNDING_INTERVAL_3600 = 1 hours; // 8hours
    uint256 public constant ONE_WITH_8_DECIMALS = 10 ** 8; //0.0001666666*100000000
    uint256 public constant BASIS_INTERVAL_HOUR_24 = 24;
    uint256 public constant DEFAULT_RATE_DIVISOR_100 = 100;

    /**
     * 计算最大单位资金费限制
     */
    /**
     *
     * @param openInterest18Decimals 18zeros
     * @param aumWith18Decimals 18zeros
     * @param maxFRatePerDayWith8Decimals 8zeros
     * @param fundingIntervalSeconds seconds
     */
    function calculateMaxFundingRate(
        uint256 openInterest18Decimals,
        uint256 aumWith18Decimals,
        uint256 maxFRatePerDayWith8Decimals,
        uint256 fundingIntervalSeconds
    ) internal pure returns (uint256) {
        uint256 _maxFRate = (
            openInterest18Decimals * fundingIntervalSeconds * maxFRatePerDayWith8Decimals * ONE_WITH_8_DECIMALS
        ) / aumWith18Decimals / BASIS_INTERVAL_HOUR_24 / ONE_WITH_8_DECIMALS / MIN_FUNDING_INTERVAL_3600;
        return _maxFRate;
    }

    /**
     * 计算单位资金费(加上最大最小限制之后)
     */
    function capFundingRateByLimits(
        uint256 long,
        uint256 short,
        uint256 maxFRate,
        uint256 minFRate,
        uint256 calculatedMaxFRate8Decimals,
        uint256 fRate,
        uint256 minority
    ) internal pure returns (uint256, uint256) {
        //- FRate<=minFRate时：FRate=minFRate（取消双边收取MinFRate）。
        /*
        if (fRate <= minFRate) return (minFRate, minFRate);
         */
        maxFRate = maxFRate == 0 ? calculatedMaxFRate8Decimals : maxFRate;
        if (fRate > maxFRate) fRate = maxFRate;
        if (fRate < minFRate) fRate = minFRate;
        return long >= short ? (fRate, minority) : (minority, fRate);
    }

    /**
     * 计算用户的资金费
     */
    function calUserFundingFee(uint256 size, int256 entryFundingRate, int256 cumRates) internal pure returns (int256) {
        // Calculate the funding fee by multiplying the position size with the rate.
        // - 收取周期负资金费方头寸为0时，正资金费>0，负资金费率为<0；收取的资金费全部用于抵扣亏损，无亏损时不发放；
        // TODO 需要和 painter 讨论
        return (int256(size) * (cumRates - entryFundingRate)) / int256(ONE_WITH_8_DECIMALS);
    }

    /**
     * 计算资金费公式
     */
    function calFeeRate(
        uint256 _longSizeWith18Decimals,
        uint256 _shortSizeWith18Decimals,
        uint256 _intervalSeconds,
        uint256 fRateFactorWith8Decimals
    ) internal pure returns (uint256) {
        // Calculate the absolute difference between longSize and shortSize.
        uint256 _size = Calc.abs(_longSizeWith18Decimals, _shortSizeWith18Decimals);
        uint256 _rate;
        if (_size != 0) {
            // Calculate the divisor by summing longSize and shortSize.
            uint256 _divisor = _longSizeWith18Decimals + _shortSizeWith18Decimals;
            // (1666-2000)/(2000+1666)

            // Calculate the fee rate.
            _rate = (_size * ONE_WITH_8_DECIMALS) / _divisor;

            // ((2000-1664)/(2000+1664) * 10**8)**2 * 3600 / (10**8) / 100 / 24 / 3600
            //350
            _rate = ((_rate ** 2) * _intervalSeconds) / ONE_WITH_8_DECIMALS / DEFAULT_RATE_DIVISOR_100
                / BASIS_INTERVAL_HOUR_24 / MIN_FUNDING_INTERVAL_3600;
            _rate = (_rate * fRateFactorWith8Decimals) / ONE_WITH_8_DECIMALS;
        }
        return _rate;
    }

    /**
     * 计算 CFRate
     * @param Long_CumFRate 多头的累计资金费率, 精度 8
     * @param Short_CumFRate 空头的累计资金费率, 精度 8
     * @param minCFRate 最小 CFRate 限制, 管理后台配置, 精度 8
     */
    function calCFRate(int256 Long_CumFRate, int256 Short_CumFRate, uint256 minCFRate)
        internal
        pure
        returns (uint256 _CFRate)
    {
        // - 资金费率 C_FRate: 每当多空仓位的FRate完成一个计算周期时(即计算出8个FRate)，多空CumFRate的差值绝对值为C_Frate；
        //   - C_FRate=| Long_CumFRate - Short_CumFRate |
        // - minC_FRate用于限制C_FRate下限(管理后台配置，区间0-1，默认为0.0001，收取最低资金费率万三每天)
        //   - C_FRate < minC_FRate 时，C_FRate取minC_FRate
        _CFRate = Calc.abs(Long_CumFRate, Short_CumFRate).toUint256();
        _CFRate = Math.max(_CFRate, minCFRate);
    }

    /**
     * 用于计算 C_FRate_Long 和 C_FRate_Short
     * @param Long_CumFRate 多头累计资金费率 8精度
     * @param Short_CumFRate 多头累计资金费率 8精度
     * @param C_FRate C_FRate 8精度
     * @param fundingFeeLossOffLimit 负资金费率公式抵扣资金亏损比例(管理后台配置) 8精度 取值范围[0,10^8]
     * @param fundingFeeLoss 单个市场记录资金费亏损总值 精度18
     * @param Size_Long Size_Long 精度18
     * @param Size_Short Size_Short 精度18
     * @return C_FRate_Long C_FRate_Long 8精度
     * @return C_FRate_Short C_FRate_Short 8精度
     */
    function calNextCFRate(
        int256 Long_CumFRate,
        int256 Short_CumFRate,
        uint256 C_FRate,
        uint256 fundingFeeLossOffLimit,
        uint256 fundingFeeLoss,
        uint256 Size_Long,
        uint256 Size_Short
    ) internal pure returns (int256 C_FRate_Long, int256 C_FRate_Short, uint256 deductFundFeeAmount) {
        //- 收取周期正资金费方头寸为0时，正资金费>0,，收取的资金费为0，负资金费率=0；
        //- 收取周期负资金费方头寸为0时，正资金费>0，负资金费率取0；
        bool isFomular = Size_Long > 0 && Size_Short > 0;
        if (Long_CumFRate >= Short_CumFRate) {
            deductFundFeeAmount = _getLossOffset(Size_Long, C_FRate, fundingFeeLossOffLimit, fundingFeeLoss);
            C_FRate_Long = C_FRate.toInt256();
            if (isFomular) {
                C_FRate_Short = -(
                    (Size_Long.toInt256() * C_FRate_Long)
                        - deductFundFeeAmount.toInt256() * ONE_WITH_8_DECIMALS.toInt256()
                ) / Size_Short.toInt256();
            }
        } else {
            deductFundFeeAmount = _getLossOffset(Size_Short, C_FRate, fundingFeeLossOffLimit, fundingFeeLoss);
            C_FRate_Short = C_FRate.toInt256();
            if (isFomular) {
                //feeLoss计算出来的一定 < Size_Short.toInt256() * C_FRate_Short
                C_FRate_Long = -(
                    (Size_Short.toInt256() * C_FRate_Short)
                        - deductFundFeeAmount.toInt256() * ONE_WITH_8_DECIMALS.toInt256()
                ) / Size_Long.toInt256();
            }
        }
    }

    /**
     * 计算资金费亏损值
     * @param size 某个方向头寸, 精度 18
     * @param _CFRate CFRate, 精度 8
     * @param fundingFeeLossOffLimit 负资金费率公式抵扣资金亏损比例(管理后台配置), 精度 8
     * @param totalLoss 单个市场记录市场剩余亏损, 精度18
     */
    // function _getFundingFeeLoss(
    function _getLossOffset(uint256 size, uint256 _CFRate, uint256 fundingFeeLossOffLimit, uint256 totalLoss)
        internal
        pure
        returns (uint256)
    {
        // 资金费亏损<= Size_Long * C_FRate_Long *10%
        return Math.min((size * _CFRate * fundingFeeLossOffLimit) / (ONE_WITH_8_DECIMALS ** 2), totalLoss);
    }

    /**
     * 共用函数, 用来获取《累计资金费率》或《累计资金费率临时值》的周期
     */
    function getFundingInterval(address market, mapping(address => uint256) storage fundingIntervals)
        internal
        view
        returns (uint256 _interval)
    {
        _interval = fundingIntervals[market];
        if (_interval == 0) return MIN_FUNDING_INTERVAL_3600;
    }

    //========================================================================
    //               TIM
    //========================================================================
    // 设 小周期别名 a，大周期别名 b
    struct FundFeeStorageMemory {
        uint256 aInterval;
        uint256 bInterval;
        uint256 aUpdatedAt;
        uint256 bUpdatedAt;
        uint256 sFRate;
        uint256 lFRate;
        int256 sCumFRate;
        int256 lCumFRate;
        uint256 fundFeeLoss;
    }

    struct FundFeeVars {
        uint256 fundFeeLoss;
        uint256 intervalsN;
        uint256 intervals1; // 第一时段间隔数
        uint256 intervals2; // 第二时段间隔数
        uint256 intervals3; // 第三时段间隔数
        uint256 updatedAt; // 在不同时段代表不同行时段的大周期更新时间
        uint256 deductAmount;
        uint256 accDeductAmount;
        int256 sCumFRate;
        int256 lCumFRate;
        int256 lCFRate;
        int256 sCFRate;
        int256 sCFRateDelta;
        int256 lCFRateDelta;
    }

    function initializeFundFeeVars(FundFeeStorageMemory memory sm) internal pure returns (FundFeeVars memory vars) {
        vars.intervalsN = sm.bInterval / sm.aInterval;
        vars.lCumFRate = sm.lCumFRate;
        vars.sCumFRate = sm.sCumFRate;
        vars.updatedAt = sm.aUpdatedAt; // 小周期更新时间, 初始化 0
        vars.fundFeeLoss = sm.fundFeeLoss;
        return vars;
    }

    // 判断是否存在前置大区间
    function needsUpdateFirstOrSecondInterval(
        FundFeeStorageMemory memory sm,
        FundFeeVars memory vars,
        uint256 currentTime
    ) internal pure returns (bool) {
        if (vars.updatedAt == 0) {
            // 时间未初始化
            vars.updatedAt = (currentTime / sm.bInterval) * sm.bInterval;
            return true;
        }

        // 当前时间 小于 小周期更新时间
        if (currentTime < vars.updatedAt) return false;

        // 大周期的更新时间 + 大周期的周期 < 当前时间
        return sm.bUpdatedAt + sm.bInterval <= currentTime;
    }

    // 判断第一时段存在的周期间隔数
    function hasFirstInterval(FundFeeStorageMemory memory sm, FundFeeVars memory vars) internal pure returns (bool) {
        // 第一段有多少个小周期剩余 = (小周期的更新时间 - 大周期的更新时间) / 小周期的秒数
        vars.intervals1 = (sm.aUpdatedAt - sm.bUpdatedAt) / sm.aInterval;
        return vars.intervals1 > 0;
    }

    // 更新第一时段结束时间和CumFRate
    function updateFirstInterval(FundFeeStorageMemory memory sm, FundFeeVars memory vars) internal pure {
        vars.updatedAt = sm.bUpdatedAt + sm.bInterval;
        vars.lCumFRate = sm.lCumFRate + (sm.lFRate * (vars.intervalsN - vars.intervals1)).toInt256();
        vars.sCumFRate = sm.sCumFRate + (sm.sFRate * (vars.intervalsN - vars.intervals1)).toInt256();
    }

    // 判断是否存在第二时段
    function hasSecondInterval(FundFeeStorageMemory memory sm, uint256 currentTime, FundFeeVars memory vars)
        internal
        pure
        returns (bool)
    {
        vars.intervals2 = (currentTime - vars.updatedAt) / sm.bInterval;
        return vars.intervals2 > 0;
    }

    // 更新第二时段结束时间和CumFRate
    function updateSecondInterval(FundFeeStorageMemory memory sm, FundFeeVars memory vars) internal pure {
        vars.updatedAt += sm.bInterval * vars.intervals2;
        vars.lCumFRate = (sm.lFRate * vars.intervalsN).toInt256();
        vars.sCumFRate = (sm.sFRate * vars.intervalsN).toInt256();
    }

    // 判断是否处理过第一时段或第二时段
    /*
    function hasFirstOrSecondInterval(
        FundFeeVars memory vars
    ) internal pure returns (bool) {
        return vars.intervals1 > 0 || vars.intervals2 > 0;
    }
    */

    // 判断是否需要更新小周期
    function updateThirdInterval(FundFeeStorageMemory memory sm, uint256 currentTime, FundFeeVars memory vars)
        internal
        pure
        returns (bool)
    {
        if (currentTime < vars.updatedAt) {
            return false;
        }
        // (当前时间 - 内存中维护的第二段的结束时间) / 小周期秒数
        vars.intervals3 = (currentTime - vars.updatedAt) / sm.aInterval;
        return vars.intervals3 > 0;
    }

    // 时段拆分:
    // // ___    |________|________|________|________|    __
    function updateFundFee(
        uint256 lSize,
        uint256 sSize,
        uint256 currentTime,
        FundFeeStorageMemory memory sm,
        uint256 minCFRate,
        uint256 fundingFeeLossOffLimit
    )
        internal
        pure
        returns (
            FundFeeVars memory vars,
            FundFeeStorageMemory memory sm2,
            FundFeeVars memory vars2,
            bool update12Interval
        )
    {
        vars = sm.initializeFundFeeVars();
        update12Interval = sm.needsUpdateFirstOrSecondInterval(vars, currentTime);
        if (update12Interval) {
            if (sm.hasFirstInterval(vars)) {
                sm.updateFirstInterval(vars);
                _updateFundFeeStorageMemory(vars, lSize, sSize, minCFRate, fundingFeeLossOffLimit);
            }
            if (sm.hasSecondInterval(currentTime, vars)) {
                sm.updateSecondInterval(vars);
                for (uint256 i = 0; i < vars.intervals2; i++) {
                    _updateFundFeeStorageMemory(vars, lSize, sSize, minCFRate, fundingFeeLossOffLimit);
                }
            }
            vars2 = abi.decode(abi.encode(vars), (FundFeeVars));
            sm2 = abi.decode(abi.encode(sm), (FundFeeStorageMemory));
            vars.lCumFRate = 0;
            vars.sCumFRate = 0;
        }
        if (sm.updateThirdInterval(currentTime, vars)) {
            vars.updatedAt += sm.aInterval * vars.intervals3;
            vars.lCumFRate += (sm.lFRate * vars.intervals3).toInt256();
            vars.sCumFRate += (sm.sFRate * vars.intervals3).toInt256();
        }
    }

    // 更新正负资金费和抵扣
    function _updateFundFeeStorageMemory(
        FundingRateCalculator.FundFeeVars memory vars,
        uint256 lSize,
        uint256 sSize,
        uint256 minCFRate,
        uint256 fundingFeeLossOffLimit
    ) internal pure {
        uint256 CFRate = calCFRate(vars.lCumFRate, vars.sCumFRate, minCFRate);
        (vars.lCFRate, vars.sCFRate, vars.deductAmount) = calNextCFRate(
            vars.lCumFRate, vars.sCumFRate, CFRate, fundingFeeLossOffLimit, vars.fundFeeLoss, lSize, sSize
        );
        vars.lCFRateDelta += vars.lCFRate;
        vars.sCFRateDelta += vars.sCFRate;
        vars.fundFeeLoss = vars.fundFeeLoss > vars.deductAmount ? vars.fundFeeLoss - vars.deductAmount : 0;
    }
}
