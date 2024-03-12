// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "../ac/LibAccessManaged.sol";

library LibOracleStore {
    bytes32 constant STORAGE_POSITION = keccak256("blex.oracle.storage");

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

    function Storage() internal pure returns (OrderStorage storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function config() external view returns (ConfigStruct memory) {
        return Storage().config;
    }

    function setMaxCumulativeDeltaDiffs(address[] memory _tokens, uint256[] memory _maxCumulativeDeltaDiffs) external {}

    function setTokens(address[] memory _tokens, uint256[] memory _tokenPrecisions) external {}

    function setCompactedPrices(uint256[] memory _priceBitArray, uint256 _timestamp) external {}

    function setPrices(address[] memory _tokens, uint256[] memory _prices, uint256 _timestamp) external onlyUpdater {
        bool shouldUpdate = _setLastUpdatedValues(_timestamp);

        if (shouldUpdate) {
            address _feed = chainPriceFeed;

            for (uint256 i = 0; i < _tokens.length; i++) {
                address token = _tokens[i];
                _setPrice(token, _prices[i], _feed);
            }
        }
    }

    function setPricesAndExecute(bytes calldata _data) external stricted {
        (address token, uint256 price, uint256 timestamp, bytes memory _vars) =
            abi.decode(_data, (address, uint256, uint256, bytes));
        _setLastUpdatedValues(timestamp);
        _setPrice(token, price, chainPriceFeed);
        _market.execOrderKey(_vars);
    }

    // under regular operation, the fastPrice (prices[token]) is returned and there is no spread returned from this function,
    // though VaultPriceFeed might apply its own spread
    //
    // if the fastPrice has not been updated within priceDuration then it is ignored and only _refPrice with a spread is used (spread: spreadBasisPointsIfInactive)
    // in case the fastPrice has not been updated for maxPriceUpdateDelay then the _refPrice with a larger spread is used (spread: spreadBasisPointsIfChainError)
    //
    // there will be a spread from the _refPrice to the fastPrice in the following cases:
    // - in case isSpreadEnabled is set to true
    // - in case the maxDeviationBasisPoints between _refPrice and fastPrice is exceeded
    // - in case watchers flag an issue
    // - in case the cumulativeFastDelta exceeds the cumulativeRefDelta by the maxCumulativeDeltaDiff
    function getPrice(address _token, uint256 _refPrice, bool _maximise) external view returns (uint256) {
        return prices[_token];
        if (block.timestamp > lastUpdatedAt + maxPriceUpdateDelay) {
            if (_maximise) {
                return (_refPrice * (BASIS_POINTS_DIVISOR + spreadBasisPointsIfChainError)) / BASIS_POINTS_DIVISOR;
            }

            return (_refPrice * (BASIS_POINTS_DIVISOR - spreadBasisPointsIfChainError)) / (BASIS_POINTS_DIVISOR);
        }

        if (block.timestamp > lastUpdatedAt + priceDuration) {
            // 300
            if (_maximise) {
                return (_refPrice * (BASIS_POINTS_DIVISOR + spreadBasisPointsIfInactive)) / BASIS_POINTS_DIVISOR;
            }

            return (_refPrice * (BASIS_POINTS_DIVISOR - spreadBasisPointsIfInactive)) / BASIS_POINTS_DIVISOR;
        }

        uint256 fastPrice = prices[_token];
        if (fastPrice == 0) {
            return _refPrice;
        }
        //  ref price   fast price
        // 160248000000 - 160029000000 = 219000000
        uint256 diffBasisPoints = _refPrice > fastPrice ? _refPrice - fastPrice : fastPrice - _refPrice;
        // 0.002
        diffBasisPoints = (diffBasisPoints * BASIS_POINTS_DIVISOR) / _refPrice;

        // create a spread between the _refPrice and the fastPrice if the maxDeviationBasisPoints is exceeded
        // or if watchers have flagged an issue with the fast price
        // 1. fastPrice
        //      1. isSpreadEnabled, false
        //      2. fastprice > chainlink, false
        // 2. 1%
        //      /
        // 3. ， fastPricechainlink/, fastPrice
        bool hasSpread = !favorFastPrice(_token) || diffBasisPoints > maxDeviationBasisPoints;

        if (hasSpread) {
            // return the higher of the two prices
            if (_maximise) {
                return _refPrice > fastPrice ? _refPrice : fastPrice;
            }

            // return the lower of the two prices
            return _refPrice < fastPrice ? _refPrice : fastPrice;
        }

        return fastPrice;
    }

    function favorFastPrice(address _token) public view returns (bool) {
        if (isSpreadEnablede) {
            return false;
        }

        (,, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta) = getPriceData(_token);
        if (
            cumulativeFastDelta > cumulativeRefDelta
                && cumulativeFastDelta - cumulativeRefDelta > maxCumulativeDeltaDiffs[_token]
        ) {
            // fast > chainlink, fast-chainlink >
            // force a spread if the cumulative delta for the fast price feed exceeds the cumulative delta
            // for the Chainlink price feed by the maxCumulativeDeltaDiff allowed
            return false;
        }

        return true;
    }

    function getPriceData(address _token) public view returns (uint256, uint256, uint256, uint256) {
        PriceDataItem memory data = priceData[_token];
        return (
            uint256(data.refPrice),
            uint256(data.refTime),
            uint256(data.cumulativeRefDelta),
            uint256(data.cumulativeFastDelta)
        );
    }

    function _setPrice(address _token, uint256 _price, address _feed) private {
        if (false && _feed != address(0)) {
            uint256 refPrice = IChainPriceFeed(_feed).getLatestPrice(_token);
            uint256 fastPrice = prices[_token];

            (uint256 prevRefPrice, uint256 refTime, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta) =
                getPriceData(_token);

            if (prevRefPrice > 0) {
                // chainlink
                uint256 refDeltaAmount = refPrice > prevRefPrice ? refPrice - prevRefPrice : prevRefPrice - refPrice;
                // fastPrice
                uint256 fastDeltaAmount = fastPrice > _price ? fastPrice - _price : _price - fastPrice;

                // reset cumulative delta values if it is a new time window
                if (refTime / priceDataInterval != block.timestamp / priceDataInterval) {
                    cumulativeRefDelta = 0;
                    cumulativeFastDelta = 0;
                }
                //
                cumulativeRefDelta = cumulativeRefDelta + (refDeltaAmount * CUMULATIVE_DELTA_PRECISION) / prevRefPrice;
                cumulativeFastDelta = cumulativeFastDelta + (fastDeltaAmount * CUMULATIVE_DELTA_PRECISION) / fastPrice;
            }

            if (
                cumulativeFastDelta > cumulativeRefDelta
                    && cumulativeFastDelta - cumulativeRefDelta > maxCumulativeDeltaDiffs[_token]
            ) {
                emit MaxCumulativeDeltaDiffExceeded(
                    _token, refPrice, fastPrice, cumulativeRefDelta, cumulativeFastDelta
                );
            }

            _setPriceData(_token, refPrice, cumulativeRefDelta, cumulativeFastDelta);
            emit PriceData(_token, refPrice, fastPrice, cumulativeRefDelta, cumulativeFastDelta);
        }

        lastUpdatedAtBlock[_token] = block.timestamp;
        prices[_token] = _price;
        emit UpdatePrice(msg.sender, _token, _price);
    }

    function _setPriceData(address _token, uint256 _refPrice, uint256 _cumulativeRefDelta, uint256 _cumulativeFastDelta)
        private
    {
        require(_refPrice < MAX_REF_PRICE, "FastPriceFeed: invalid refPrice");
        // skip validation of block.timestamp, it should only be out of range after the year 2100
        require(_cumulativeRefDelta < MAX_CUMULATIVE_REF_DELTA, "FastPriceFeed: invalid cumulativeRefDelta");
        require(_cumulativeFastDelta < MAX_CUMULATIVE_FAST_DELTA, "FastPriceFeed: invalid cumulativeFastDelta");

        priceData[_token] = PriceDataItem(
            uint160(_refPrice), uint32(block.timestamp), uint32(_cumulativeRefDelta), uint32(_cumulativeFastDelta)
        );
    }

    function _setLastUpdatedValues(uint256 _timestamp) private returns (bool) {
        if (minBlockInterval > 0) {
            require(
                block.number - lastUpdatedBlock >= minBlockInterval, "FastPriceFeed: minBlockInterval not yet passed"
            );
        }

        uint256 _maxTimeDeviation = maxTimeDeviation;
        require(_timestamp > block.timestamp - _maxTimeDeviation, "FastPriceFeed: _timestamp below allowed range");
        require(_timestamp < block.timestamp + _maxTimeDeviation, "FastPriceFeed: _timestamp exceeds allowed range");

        // do not update prices if _timestamp is before the current lastUpdatedAt value
        if (_timestamp < lastUpdatedAt) {
            return false;
        }

        lastUpdatedAt = _timestamp;
        lastUpdatedBlock = block.number;

        return true;
    }
    //==================================================================================================
    //==================================================================================================

    function getPrice(address _token, bool _maximise) public view returns (uint256) {
        uint256 price = _getPrice(_token, _maximise);

        uint256 adjustmentBps = adjustmentBasisPoints[_token];

        if (adjustmentBps > 0) {
            if (isAdjustmentAdditive[_token]) {
                return (price * (BASIS_POINTS_DIVISOR + adjustmentBps)) / BASIS_POINTS_DIVISOR;
            }
            return (price * (BASIS_POINTS_DIVISOR - adjustmentBps)) / BASIS_POINTS_DIVISOR;
        }
        return price;
    }

    function _getPrice(address _token, bool _maximise) internal view returns (uint256) {
        uint256 price = getChainPrice(_token, _maximise);

        if (isFastPriceEnabled) {
            price = getFastPrice(_token, price, _maximise);
        }

        if (isGmxPriceEnabled) {
            uint256 _gmxPrice = getGmxPrice(_token, _maximise);
            // get the higher of the two prices
            if (_maximise && _gmxPrice > price) {
                price = _gmxPrice;
            }
            // get the lower of the two prices
            if (!_maximise && price > _gmxPrice) {
                price = _gmxPrice;
            }
        }

        if (strictStableTokens[_token]) {
            uint256 delta = price > ONE_USD ? price - ONE_USD : ONE_USD - price;
            if (delta <= maxStrictPriceDeviation) {
                return ONE_USD;
            }

            // if _maximise and price is e.g. 1.02, return 1.02
            if (_maximise && price > ONE_USD) {
                return price;
            }

            // if !_maximise and price is e.g. 0.98, return 0.98
            if (!_maximise && price < ONE_USD) {
                return price;
            }

            return ONE_USD;
        }

        uint256 _spreadBasisPoints = spreadBasisPoints[_token];

        if (_maximise) {
            return (price * (BASIS_POINTS_DIVISOR + _spreadBasisPoints)) / BASIS_POINTS_DIVISOR;
        }
        return (price * (BASIS_POINTS_DIVISOR - _spreadBasisPoints)) / BASIS_POINTS_DIVISOR;
    }
    //==================================================================================================
    //==================================================================================================
    //==================================================================================================

    function getChainPrice(address _token, bool _maximise) public view returns (uint256) {
        uint256 xxxUSD = _getPrice(_token, _maximise);
        uint256 _USDTUSD = _getPrice(USDT, _maximise);
        if (xxxUSD < (2 ** 256 - 1) / PRICE_PRECISION) {
            return (xxxUSD * PRICE_PRECISION) / _USDTUSD;
        }
        return (xxxUSD / PRICE_PRECISION) * _USDTUSD;
    }

    function _getChainPrice(address _token, bool _maximise) private view returns (uint256) {
        address _feed = priceFeeds[_token];
        require(_feed != address(0), "PriceFeed: invalid price feed");

        IPriceFeed _priceFeed = IPriceFeed(_feed);

        uint256 _price = 0;
        uint80 _id = _priceFeed.latestRound();

        for (uint80 i = 0; i < sampleSpace; i++) {
            if (_id <= i) {
                break;
            }
            uint256 p;

            if (i == 0) {
                int256 _p = _priceFeed.latestAnswer();
                require(_p > 0, "PriceFeed: invalid price");
                p = uint256(_p);
            } else {
                (, int256 _p,,,) = _priceFeed.getRoundData(_id - i);
                require(_p > 0, "PriceFeed: invalid price");
                p = uint256(_p);
            }

            if (_price == 0) {
                _price = p;
                continue;
            }

            if (_maximise && p > _price) {
                _price = p;
                continue;
            }

            if (!_maximise && p < _price) {
                _price = p;
            }
        }

        require(_price > 0, "PriceFeed: could not fetch price");

        uint256 _decimals = priceDecimals[_token];
        return (_price * PRICE_PRECISION) / (10 ** _decimals);
    }
}
