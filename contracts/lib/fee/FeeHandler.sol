// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FeeType} from "./FeeType.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {MarketDataTypes} from "../../market/MarketDataTypes.sol";

library LibFee {
    using SafeCast for int256;

    bytes32 constant FEE_STORAGE_POSITION = keccak256("blex.fee.storage");
    uint256 constant PRECISION = 10 ** 18;

    struct FeeStorage {
        // =========================================================================
        //                            FundFeeStore & FundFee
        // =========================================================================
        mapping(uint16 market => uint256 interval) fundingIntervals;
        mapping(uint8 configType => uint256 value) configs;
        mapping(uint16 market => uint256 calInterval) calIntervals;
        mapping(uint16 market => uint256 lastCalTime) lastCalTimes;
        mapping(uint16 market => mapping(bool isLong => int256 calFundingRate)) calFundingRates;
        mapping(uint16 market => uint256 loss) fundFeeLoss;
        mapping(uint16 market => uint256 balance) balances;
        // =========================================================================
        //                            FeeRouter
        // =========================================================================
        // market's feeRate and fee
        mapping(uint16 market => mapping(uint8 feeType => uint256 feeAndRate)) feeAndRates;
        // FeeVault-storage
        // cumulativeFundingRates tracks the funding rates based on utilization
        mapping(uint16 market => mapping(bool isLong => int256)) cumulativeFundingRates;
        // fundingRates tracks the funding rates based on position size
        mapping(uint16 market => mapping(bool isLong => int256)) fundingRates;
        // lastFundingTimes tracks the last time funding was updated for a token
        mapping(uint16 market => uint256) lastFundingTimes;
    }

    function initialize(address feeVault_, address factory_) internal {
        FeeStorage storage fs = Storage();
        fs.feeVault = feeVault_;
        fs.factory = factory_;
        fs.marketReader = marketReader_;
        fs.configs[uint8(ConfigType.MaxFRatePerDay)] = PRECISION;
        fs.configs[uint8(ConfigType.FRateFactor)] = PRECISION;
        fs.configs[uint8(ConfigType.MinFRate)] = 1250;
        fs.configs[uint8(ConfigType.MinFundingInterval)] = 1 hours;
        fs.configs[uint8(ConfigType.FundingFeeLossOffLimit)] = 1e7;
    }

    enum ConfigType {
        SkipTime,
        MaxFRatePerDay,
        FRateFactor,
        MaxFRate,
        MinFRate,
        FeeLoss,
        MinFundingInterval,
        MinorityFRate,
        MinCFRate,
        FundingFeeLossOffLimit,
        Counter
    }

    function Storage() internal pure returns (FeeStorage storage fs) {
        bytes32 position = FEE_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function setFeeVault(address feeVault_) internal {
        Storage().feeVault = feeVault_;
    }

    function setMarketReader(uint16 marketReader_) internal {
        Storage().marketReader = marketReader_;
    }

    function setFundingIntervals(uint16 market, uint256 interval) internal {
        Storage().fundingIntervals[market] = interval;
    }

    function setConfigs(uint8 configType, uint256 value) internal {
        Storage().configs[configType] = value;
    }

    function setCalIntervals(uint16 market, uint256 interval) internal {
        Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(uint16 market, uint256 lastCalTime) internal {
        Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(uint16 market, bool isLong, int256 calFundingRate) internal {
        Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(uint16 market, uint256 loss) internal {
        Storage().fundFeeLoss[market] = loss;
    }

    function setFactory(address factory_) internal {
        Storage().factory = factory_;
    }

    function setFeeAndRates(uint16 market, uint8 feeType, uint256 feeAndRate) internal {
        Storage().feeAndRates[market][feeType] = feeAndRate;
    }

    function feeVault() internal view returns (address) {
        return Storage().feeVault;
    }

    function fundingIntervals(uint16 market) internal view returns (uint256 fundingInterval) {
        return Storage().fundingIntervals[market];
    }

    function configs(uint8 configType) internal view returns (uint256 value) {
        return Storage().configs[configType];
    }

    function calIntervals(uint16 market) internal view returns (uint256 calInterval) {
        return Storage().calIntervals[market];
    }

    function lastCalTimes(uint16 market) internal view returns (uint256 lastCalTime) {
        return Storage().lastCalTimes[market];
    }

    function calFundingRates(uint16 market, bool isLong) internal view returns (int256 calFundingRate) {
        return Storage().calFundingRates[market][isLong];
    }

    function fundFeeLoss(uint16 market) internal view returns (uint256 loss) {
        return Storage().fundFeeLoss[market];
    }

    function factory() internal view returns (address) {
        return Storage().factory;
    }

    function feeAndRates(uint16 market, uint8 feeType) internal view returns (uint256 feeAndRate) {
        return Storage().feeAndRates[market][feeType];
    }
    /**
     * 只是获取根据当前仓位获取各种费用应该收取多少, 并不包含收费顺序和是否能收得到
     * @param params 用户传参
     * @param _fundFee 资金费
     * @param feeAndRates 费率参数
     */

    function getFees(MarketDataTypes.UpdatePositionInputs memory params, int256 _fundFee)
        internal
        view
        returns (int256[] memory fees)
    {
        fees = new int256[](uint8(FeeType.T.Counter));
        address _market = params._market;
        fees[uint8(FeeType.T.FundFee)] = _fundFee;

        if (params._sizeDelta == 0 && params.collateralDelta != 0) {
            return fees;
        }

        // open position
        if (params.isOpen) {
            fees[uint8(FeeType.T.OpenFee)] = int256(getFee(_market, params._sizeDelta, uint8(FeeType.T.OpenFee)));
        } else {
            // close position
            fees[uint8(FeeType.T.CloseFee)] = int256(getFee(_market, params._sizeDelta, uint8(FeeType.T.CloseFee)));

            // liquidate position
            if (params.liqState == 1) {
                uint256 _fee = Storage().feeAndRates[_market][uint8(FeeType.T.LiqFee)];
                fees[uint8(FeeType.T.LiqFee)] = int256(_fee);
            }
        }
        if (params.execNum > 0) {
            // exec fee
            uint256 _fee = Storage().feeAndRates[_market][uint8(FeeType.T.ExecFee)];
            _fee = _fee * params.execNum;

            fees[uint8(FeeType.T.ExecFee)] = int256(_fee);
        }
        return fees;
    }

    /**
     * @dev Calculates the fee for a given size delta and fee kind.
     * @param market The address of the market.
     * @param sizeDelta The change in position size.
     * @param kind The fee kind.
     * @return The fee amount.
     */
    function getFee(address market, uint256 sizeDelta, uint8 kind) internal view returns (uint256) {
        if (sizeDelta == 0) {
            return 0;
        }

        uint256 _point = Storage().feeAndRates[market][kind];
        if (_point == 0) {
            _point = PRECISION;
        }

        uint256 _size = (sizeDelta * (PRECISION - _point)) / PRECISION;
        return sizeDelta - _size;
    }
}
