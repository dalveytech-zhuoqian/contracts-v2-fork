// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamond} from "../diamond-2/contracts/libraries/LibDiamond.sol";

library LibFundFee {
    bytes32 constant FEE_STORAGE_POSITION = keccak256("blex.fee.storage");
    uint256 public constant PRECISION = 10 ** 8;

    struct FeeStorage {
        bool initialized;
        // =========================================================================
        //                            FundFeeStore & FundFee
        // =========================================================================
        address feeVault;
        address marketReader;
        mapping(address market => uint256 interval) fundingIntervals;
        mapping(uint8 configType => uint256 value) configs;
        mapping(address market => uint256 calInterval) calIntervals;
        mapping(address market => uint256 lastCalTime) lastCalTimes;
        mapping(address market => mapping(bool isLong => int256 calFundingRate)) calFundingRates;
        mapping(address market => uint256 loss) fundFeeLoss;
        // =========================================================================
        //                            FeeRouter
        // =========================================================================
        // address feeVault; @Deprecated
        // address fundFee; @Deprecated
        address factory;
        // market's feeRate and fee
        mapping(address market => mapping(uint8 feeType => uint256 feeAndRate)) feeAndRates;

        // FeeVault-storage
        // cumulativeFundingRates tracks the funding rates based on utilization
        mapping(address => mapping(bool => int256)) public cumulativeFundingRates;
        // fundingRates tracks the funding rates based on position size
        mapping(address => mapping(bool => int256)) public fundingRates;
        // lastFundingTimes tracks the last time funding was updated for a token
        mapping(address => uint256) public lastFundingTimes;
    }

    function initialize(address feeVault_, address factory_, address marketReader_) internal {
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

    enum FeeType {
        OpenFee,
        CloseFee,
        FundFee,
        ExecFee,
        LiqFee,
        BuyLpFee,
        SellLpFee,
        ExtraFee0,
        ExtraFee1,
        ExtraFee2,
        ExtraFee3,
        ExtraFee4,
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

    function setMarketReader(address marketReader_) internal {
        Storage().marketReader = marketReader_;
    }

    function setFundingIntervals(address market, uint256 interval) internal {
        Storage().fundingIntervals[market] = interval;
    }

    function setConfigs(uint8 configType, uint256 value) internal {
        Storage().configs[configType] = value;
    }

    function setCalIntervals(address market, uint256 interval) internal {
        Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(address market, uint256 lastCalTime) internal {
        Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(address market, bool isLong, int256 calFundingRate) internal {
        Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(address market, uint256 loss) internal {
        Storage().fundFeeLoss[market] = loss;
    }

    function setFactory(address factory_) internal {
        Storage().factory = factory_;
    }

    function setFeeAndRates(address market, uint8 feeType, uint256 feeAndRate) internal {
        Storage().feeAndRates[market][feeType] = feeAndRate;
    }

    function feeVault() internal view returns (address) {
        return Storage().feeVault;
    }

    function marketReader() internal view returns (address){
        return Storage().marketReader;
    }

    function fundingIntervals(address market) internal view returns (uint256 fundingInterval){
        return Storage().fundingIntervals[market];
    }

    function configs(uint8 configType) internal view returns (uint256 value){
        return Storage().configs[configType];
    }

    function calIntervals(address market) internal view returns (uint256 calInterval){
        return Storage().calIntervals[market];
    }

    function lastCalTimes(address market) internal view returns (uint256 lastCalTime){
        return Storage().lastCalTimes[market];
    }

    function calFundingRates(address market, bool isLong) internal view returns (int256 calFundingRate){
        return Storage().calFundingRates[market][isLong];
    }

    function fundFeeLoss(address market) internal view returns (uint256 loss){
        return Storage().fundFeeLoss[market];
    }

    function factory() internal view returns (address){
        return Storage().factory;
    }

    function feeAndRates(address market, uint8 feeType) internal view returns (uint256 feeAndRate){
        return Storage().feeAndRates[market][feeType];
    }
}
