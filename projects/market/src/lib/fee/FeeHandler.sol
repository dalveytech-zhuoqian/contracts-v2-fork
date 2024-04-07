// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../types/Types.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {FundingRateCalculator} from "./FundingRateCalculator.sol";
import {PercentageMath} from "../utils/PercentageMath.sol";

library FeeHandler {
    using SafeCast for int256;
    using SafeERC20 for IERC20;
    using PercentageMath for uint256;

    bytes32 constant FEE_STORAGE_POSITION = keccak256("blex.fee.storage");

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

    event UpdateFundInterval(uint16 indexed market, uint256 interval);
    event UpdateCalInterval(uint16 indexed market, uint256 interval);
    event AddSkipTime(uint256 indexed startTime, uint256 indexed endTime);
    event UpdateConfig(uint256 index, uint256 oldFRate, uint256 newFRate);
    event UpdateFee(address indexed account, uint16 indexed market, int256[] fees, uint256 amount);
    event UpdateFeeAndRates(uint16 indexed market, uint8 kind, uint256 oldFeeOrRate, uint256 feeOrRate);
    event UpdateCumulativeFundRate(uint16 indexed market, int256 longRate, int256 shortRate);
    event UpdateFundRate(uint16 indexed market, int256 longRate, int256 shortRate);
    event UpdateLastFundTime(uint16 indexed market, uint256 timestamp);
    event AddNegativeFeeLoss(
        uint16 indexed market, address account, uint256 amount, uint256 lossBefore, uint256 lossAfter
    );

    function initialize(uint16 market) internal {
        FeeStorage storage fs = Storage();
        fs.configs[market][uint8(ConfigType.MaxFRatePerDay)] = PercentageMath.PERCENTAGE_FACTOR;
        fs.configs[market][uint8(ConfigType.FRateFactor)] = PercentageMath.PERCENTAGE_FACTOR;
        fs.configs[market][uint8(ConfigType.MinFRate)] = 1250;
        fs.configs[market][uint8(ConfigType.MinFundingInterval)] = 1 hours;
        fs.configs[market][uint8(ConfigType.FundingFeeLossOffLimit)] = 0.1e7;
    }

    function Storage() internal pure returns (FeeStorage storage fs) {
        bytes32 position = FEE_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function getOrderFees(bytes memory params) internal view returns (int256 fees) {
        //todo
    }

    function getExecFee(uint16 market) external view returns (uint256) {
        //todo
    }

    function payoutFees(address account, address token, int256[] memory fees, uint256 feesTotal) internal {
        // todo
    }

    function getFundingRate(uint16 market, bool isLong) internal view returns (int256) {
        // todo
    }

    function totalFees(int256[] memory fees) internal pure returns (int256 total) {
        for (uint256 i = 0; i < fees.length; i++) {
            total += fees[i];
        }
    }

    function getFees(bytes calldata data) internal view returns (int256[] memory) {
        (MarketCache memory params, PositionProps memory _position) = abi.decode(data, (MarketCache, PositionProps));

        //todo
    }

    /**
     * 只是获取根据当前仓位获取各种费用应该收取多少, 并不包含收费顺序和是否能收得到
     */
    function getFeesReceivable(MarketCache memory params, int256 _fundFee)
        internal
        view
        returns (int256[] memory fees)
    {
        // todo merge with feeAndRates?
        fees = new int256[](uint8(FeeType.Counter));

        fees[uint8(FeeType.FundFee)] = _fundFee;

        if (params.sizeDelta == 0 && params.collateralDelta != 0) {
            return fees;
        }

        // open position
        if (params.isOpen) {
            fees[uint8(FeeType.OpenFee)] = int256(getFeeOfKind(params.market, params.sizeDelta, uint8(FeeType.OpenFee)));
        } else {
            // close position
            fees[uint8(FeeType.CloseFee)] =
                int256(getFeeOfKind(params.market, params.sizeDelta, uint8(FeeType.CloseFee)));

            // liquidate position
            if (params.liqState == LiquidationState.Collateral) {
                uint256 _fee = Storage().feeAndRates[params.market][uint8(FeeType.LiqFee)];
                fees[uint8(FeeType.LiqFee)] = int256(_fee);
            }
        }
        if (params.execNum > 0) {
            // exec fee
            uint256 _fee = Storage().feeAndRates[params.market][uint8(FeeType.ExecFee)];
            _fee = _fee * params.execNum;

            fees[uint8(FeeType.ExecFee)] = int256(_fee);
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
    function getFeeOfKind(uint16 market, uint256 sizeDelta, uint8 kind) internal view returns (uint256) {
        if (sizeDelta == 0) {
            return 0;
        }

        uint256 _point = PercentageMath.maxPctIfZero(Storage().feeAndRates[market][kind]);
        return sizeDelta.percentMul(_point);
    }

    //==========================================================================================
    //        private functions
    //==========================================================================================

    function _updateGlobalFundingRate(
        uint16 market,
        int256 longRate,
        int256 shortRate,
        int256 longRateDelta,
        int256 shortRateDelta,
        uint256 timestamp
    ) private {
        // DONE
        Storage().cumulativeFundingRates[market][true] += longRateDelta;
        Storage().cumulativeFundingRates[market][false] += shortRateDelta;
        Storage().fundingRates[market][true] = longRate;
        Storage().fundingRates[market][false] = shortRate;
        Storage().lastFundingTimes[market] = timestamp;

        emit UpdateCumulativeFundRate(market, longRateDelta, shortRateDelta);
        emit UpdateFundRate(market, longRate, shortRate);
        emit UpdateLastFundTime(market, timestamp);
    }

    function _getLastCollectTimes(uint16 market) private view returns (uint256) {
        return Storage().lastFundingTimes[market];
    }

    function _calFeeRate(uint16 _market, uint256 _longSize, uint256 _shortSize) private view returns (uint256) {}

    function _getMaxFRate(uint16 market, uint256 openInterest, uint256 aum) internal view returns (uint256) {
        uint256 fundingInterval = _getCalInterval(market);
        return FundingRateCalculator.calculateMaxFundingRate(openInterest, aum, maxFRatePerDay(market), fundingInterval);
    }

    function _getCalInterval(uint16 market) private view returns (uint256 _interval) {
        FeeStorage storage fs = Storage();
        _interval = fs.fundingIntervals[market];
        if (_interval == 0) return FundingRateCalculator.MIN_FUNDING_INTERVAL_3600;
    }

    function maxFRatePerDay(uint16 market) internal view returns (uint256) {
        FeeStorage storage fs = Storage();
        return fs.configs[market][uint8(ConfigType.MaxFRatePerDay)];
    }

    function getCalFundingRates(address market) internal view returns (int256, int256) {
        //todo
    }

    function getFundingFee(address market, uint256 size, int256 entryFundingRate, bool isLong)
        internal
        view
        returns (int256)
    {
        //todo
    }
}
