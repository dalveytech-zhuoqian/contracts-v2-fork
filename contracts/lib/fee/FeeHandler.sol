// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {FeeType} from "../types/FeeType.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {MarketDataTypes} from "../types/MarketDataTypes.sol";

library FeeHandler {
    using SafeCast for int256;

    bytes32 constant FEE_STORAGE_POSITION = keccak256("blex.fee.storage");
    uint256 constant PRECISION = 10 ** 18;

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

    struct FeeStorage {
        // =========================================================================
        //                            FundFeeStore & FundFee
        // =========================================================================
        mapping(uint16 market => uint256 interval) fundingIntervals;
        mapping(uint16 market => mapping(uint8 configType => uint256 value)) configs;
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

    // FundFee
    event UpdateFundInterval(address indexed market, uint256 interval);
    event UpdateCalInterval(address indexed market, uint256 interval);
    event AddSkipTime(uint256 indexed startTime, uint256 indexed endTime);
    event UpdateConfig(uint256 index, uint256 oldFRate, uint256 newFRate);

    // FeeRouter
    event UpdateFee(address indexed account, address indexed market, int256[] fees, uint256 amount);
    event UpdateFeeAndRates(address indexed market, uint8 kind, uint256 oldFeeOrRate, uint256 feeOrRate);
    //================================================================================
    // feevault
    //================================================================================
    event FeeVaultWithdraw(address indexed token, address indexed to, uint256 amount);
    event UpdateCumulativeFundRate(address indexed market, int256 longRate, int256 shortRate);
    event UpdateFundRate(address indexed market, int256 longRate, int256 shortRate);
    event UpdateLastFundTime(address indexed market, uint256 timestamp);
    //================================================================================

    function initialize(uint16 market) internal {
        FeeStorage storage fs = Storage();
        fs.configs[market][uint8(ConfigType.MaxFRatePerDay)] = PRECISION;
        fs.configs[market][uint8(ConfigType.FRateFactor)] = PRECISION;
        fs.configs[market][uint8(ConfigType.MinFRate)] = 1250;
        fs.configs[market][uint8(ConfigType.MinFundingInterval)] = 1 hours;
        fs.configs[market][uint8(ConfigType.FundingFeeLossOffLimit)] = 1e7;
    }

    function Storage() internal pure returns (FeeStorage storage fs) {
        bytes32 position = FEE_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function collectFees(bytes memory data) external {
        // address account,
        // address token,
        // int256[] memory fees
        // uint256 fundfeeLoss
    }
    function payoutFees(bytes memory data) external {
        // address account,
        // address token,
        // int256[] memory fees,
        // int256 feesTotal
    }
    function updateCumulativeFundingRate(bytes memory data) external {
        // uint16 market,
        // uint256 longSize,
        // uint256 shortSize
    }

    function updateGlobalFundingRate(
        uint16 market,
        int256 longRate,
        int256 shortRate,
        int256 nextLongRate,
        int256 nextShortRate,
        uint256 timestamp
    ) external {}

    /**
     * 只是获取根据当前仓位获取各种费用应该收取多少, 并不包含收费顺序和是否能收得到
     */

    function getFees(MarketDataTypes.Cache memory params, int256 _fundFee)
        internal
        view
        returns (int256[] memory fees)
    {
        fees = new int256[](uint8(FeeType.T.Counter));

        fees[uint8(FeeType.T.FundFee)] = _fundFee;

        if (params.sizeDelta == 0 && params.collateralDelta != 0) {
            return fees;
        }

        // open position
        if (params.isOpen) {
            fees[uint8(FeeType.T.OpenFee)] = int256(getFee(params.market, params.sizeDelta, uint8(FeeType.T.OpenFee)));
        } else {
            // close position
            fees[uint8(FeeType.T.CloseFee)] = int256(getFee(params.market, params.sizeDelta, uint8(FeeType.T.CloseFee)));

            // liquidate position
            if (params.liqState == 1) {
                uint256 _fee = Storage().feeAndRates[params.market][uint8(FeeType.T.LiqFee)];
                fees[uint8(FeeType.T.LiqFee)] = int256(_fee);
            }
        }
        if (params.execNum > 0) {
            // exec fee
            uint256 _fee = Storage().feeAndRates[params.market][uint8(FeeType.T.ExecFee)];
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
    function getFee(uint16 market, uint256 sizeDelta, uint8 kind) internal view returns (uint256) {
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
