// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "../ac/LibAccessManaged.sol";

library LibOracleStore {
    uint256 constant MAX_SPREAD_BASIS_POINTS = 50;
    uint256 constant MAX_ADJUSTMENT_INTERVAL = 2 hours;
    uint256 constant MAX_ADJUSTMENT_BASIS_POINTS = 20;

    uint256 constant PRICE_PRECISION = 10 ** 30;
    uint256 constant ONE_USD = PRICE_PRECISION;

    uint256 constant CUMULATIVE_DELTA_PRECISION = 10 * 1000 * 1000;
    uint256 constant MAX_REF_PRICE = type(uint160).max;
    uint256 constant MAX_CUMULATIVE_REF_DELTA = type(uint32).max;
    uint256 constant MAX_CUMULATIVE_FAST_DELTA = type(uint32).max;
    // uint256(~0) is 256 bits of 1s
    // shift the 1s by (256 - 32) to get (256 - 32) 0s followed by 32 1s
    uint256 constant BITMASK_32 = type(uint256).max >> (256 - 32);
    uint256 constant BASIS_POINTS_DIVISOR = 10000;
    uint256 constant MAX_PRICE_DURATION = 30 minutes;

    // fit data in a uint256 slot to save gas costs
    struct PriceDataItem {
        uint160 refPrice; // Chainlink price
        uint32 refTime; // last updated at time
        uint32 cumulativeRefDelta; // cumulative Chainlink price delta
        uint32 cumulativeFastDelta; // cumulative fast price delta
    }

    struct ConfigStruct {
        bool isSpreadEnablede;
        bool isFastPriceEnabled;
        bool isGmxPriceEnabled;
        uint32 lastUpdatedBlock;
        uint32 minBlockInterval;
        uint32 lastUpdatedAt;
        // allowed deviation from primary price
        uint32 maxDeviationBasisPoints; //1000
        uint32 priceDuration; // 300
        uint32 maxPriceUpdateDelay; //3600
        uint32 spreadBasisPointsIfInactive;
        uint32 spreadBasisPointsIfChainError;
        uint32 spreadThresholdBasisPoints; //= 30;
        uint32 maxTimeDeviation;
        uint32 priceDataInterval;
        uint32 sampleSpace; //  3
        uint32 maxStrictPriceDeviation; //= 0;
    }

    struct StorageStruct {
        ConfigStruct config;
        // array of tokens used in setCompactedPrices, saves L1 calldata gas costs
        address[] tokens;
        // array of tokenPrecisions used in setCompactedPrices, saves L1 calldata gas costs
        // if the token price will be sent with 3 decimals, then tokenPrecision for that token
        // should be 10 ** 3
        uint256[] tokenPrecisions;
        uint256[] updatedAt;
        // Chainlink can return prices for stablecoins
        // that differs from 1 USD by a larger percentage than stableSwapFeeBasisPoints
        // we use strictStableTokens to cap the price to 1 USD
        // this allows us to configure stablecoins like DAI as being a stableToken
        // while not being a strictStableToken
        mapping(address => bool) strictStableTokens;
        mapping(address => bool) isAdjustmentAdditive;
        mapping(address => address) priceFeeds;
        mapping(address => uint256) spreadBasisPoints;
        mapping(address => uint256) adjustmentBasisPoints;
        mapping(address => uint256) lastAdjustmentTimings;
        mapping(address => uint256) priceDecimals;
        mapping(address => uint256) lastUpdatedAtBlock;
        mapping(address => uint256) prices;
        mapping(address => uint256) maxCumulativeDeltaDiffs;
        mapping(address => PriceDataItem) priceData;
    }

    event PriceData(
        address token, uint256 refPrice, uint256 fastPrice, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta
    );
    event MaxCumulativeDeltaDiffExceeded(
        address token, uint256 refPrice, uint256 fastPrice, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta
    );
    event UpdatePrice(address feed, address indexed token, uint256 price);

    function setPriceFeed(address _feed) external {}

    function setMaxTimeDeviation(uint256 _deviation) external {}

    function setPriceDuration(uint256 _duration) external {}

    function setMaxPriceUpdateDelay(uint256 _delay) external {}

    function setSpreadBasisPointsIfInactive(uint256 _point) external {}

    function setSpreadBasisPointsIfChainError(uint256 _point) external {}

    function setMinBlockInterval(uint256 _interval) external {}

    function setIsSpreadEnabled(bool _enabled) external {}

    function setLastUpdatedAt(uint256 _lastUpdatedAt) external {}

    function setMaxDeviationBasisPoints(uint256 _maxDeviationBasisPoints) external {}

    function setMaxCumulativeDeltaDiffs(address[] memory _tokens, uint256[] memory _maxCumulativeDeltaDiffs) external {}

    function setPriceDataInterval(uint256 _priceDataInterval) external {}

    function setTokens(address[] memory _tokens, uint256[] memory _tokenPrecisions) external {}

    function setCompactedPrices(uint256[] memory _priceBitArray, uint256 _timestamp) external {}
}
