// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPriceFeed} from "../../interfaces/IPriceFeed.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library OracleHandler {
    using SafeCast for uint256;
    using SafeCast for int256;

    bytes32 constant STORAGE_POSITION = keccak256("blex.oracle.storage");
    uint256 constant PRICE_PRECISION = 10 ** 30;
    uint256 constant ONE_USD = PRICE_PRECISION;
    uint256 constant CUMULATIVE_DELTA_PRECISION = 10 * 1000 * 1000;
    uint256 constant MAX_REF_PRICE = type(uint160).max;
    uint256 constant MAX_CUMULATIVE_REF_DELTA = type(uint32).max;
    uint256 constant MAX_CUMULATIVE_FAST_DELTA = type(uint32).max;
    uint256 constant BASIS_POINTS_DIVISOR = 10000;

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
        uint32 maxDeviationBasisPoints; //1000
        uint32 priceDuration; // 300
        uint32 maxPriceUpdateDelay; //3600
        uint32 spreadBasisPointsIfInactive;
        uint32 spreadBasisPointsIfChainError;
        uint32 priceDataInterval;
        uint32 sampleSpace; //  3
    }

    struct StorageStruct {
        address USDT;
        ConfigStruct config;
        // Chainlink can return prices for stablecoins
        // that differs from 1 USD by a larger percentage than stableSwapFeeBasisPoints
        // this allows us to configure stablecoins like DAI as being a stableToken
        // while not being a strictStableToken
        mapping(uint16 => bool) isAdjustmentAdditive;
        mapping(uint16 => address) priceFeeds;
        mapping(uint16 => uint256) spreadBasisPoints;
        mapping(uint16 => uint256) adjustmentBasisPoints;
        mapping(uint16 => uint256) lastAdjustmentTimings;
        mapping(uint16 => uint256) prices;
        mapping(uint16 => uint256) maxCumulativeDeltaDiffs;
        mapping(uint16 => PriceDataItem) priceData;
    }

    event PriceData(
        uint16 market, uint256 refPrice, uint256 fastPrice, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta
    );
    event MaxCumulativeDeltaDiffExceeded(
        uint16 market, uint256 refPrice, uint256 fastPrice, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta
    );
    event UpdatePrice(address feed, uint16 indexed market, uint256 price);

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function config() internal view returns (ConfigStruct memory) {
        return Storage().config;
    }

    function setPrices(uint16[] memory _markets, uint256[] memory _prices) internal {
        for (uint256 i = 0; i < _markets.length; i++) {
            _setPrice(_markets[i], _prices[i]);
        }
    }

    function setPrice(uint16 _market, uint256 _price) internal {
        _setPrice(_market, _price);
    }
    //==================================================================================================
    //================ view    functions================================================================
    //==================================================================================================

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

    function getPrice(uint16 market, bool _maximise) internal view returns (uint256) {
        uint256 price = _getPrice(market, _maximise);
        uint256 adjustmentBps = Storage().adjustmentBasisPoints[market];
        if (adjustmentBps > 0) {
            if (Storage().isAdjustmentAdditive[market]) {
                return (price * (BASIS_POINTS_DIVISOR + adjustmentBps)) / BASIS_POINTS_DIVISOR;
            }
            return (price * (BASIS_POINTS_DIVISOR - adjustmentBps)) / BASIS_POINTS_DIVISOR;
        }
        return price;
    }

    function getFastPrice(uint16 market, uint256 _refPrice, bool _maximise) internal view returns (uint256) {
        uint256 lastUpdate = uint256(Storage().priceData[market].refTime);
        if (block.timestamp > lastUpdate + uint256(Storage().config.maxPriceUpdateDelay)) {
            if (_maximise) {
                return (_refPrice * (BASIS_POINTS_DIVISOR + uint256(Storage().config.spreadBasisPointsIfChainError)))
                    / BASIS_POINTS_DIVISOR;
            }

            return (_refPrice * (BASIS_POINTS_DIVISOR - uint256(Storage().config.spreadBasisPointsIfChainError)))
                / (BASIS_POINTS_DIVISOR);
        }

        if (block.timestamp > lastUpdate + uint256(Storage().config.priceDuration)) {
            if (_maximise) {
                return (_refPrice * (BASIS_POINTS_DIVISOR + uint256(Storage().config.spreadBasisPointsIfInactive)))
                    / BASIS_POINTS_DIVISOR;
            }

            return (_refPrice * (BASIS_POINTS_DIVISOR - uint256(Storage().config.spreadBasisPointsIfInactive)))
                / BASIS_POINTS_DIVISOR;
        }

        uint256 fastPrice = Storage().prices[market];
        if (fastPrice == 0) {
            return _refPrice;
        }

        uint256 diffBasisPoints = _refPrice > fastPrice ? _refPrice - fastPrice : fastPrice - _refPrice;
        diffBasisPoints = (diffBasisPoints * BASIS_POINTS_DIVISOR) / _refPrice;

        // create a spread between the _refPrice and the fastPrice if the maxDeviationBasisPoints is exceeded
        // or if watchers have flagged an issue with the fast price
        // 1. fastPrice
        //      1. isSpreadEnabled, false
        //      2. fastprice > chainlink, false
        // 2. 1%
        // 3. fastPricechainlink/, fastPrice

        bool hasSpread = !favorFastPrice(market) || diffBasisPoints > uint256(Storage().config.maxDeviationBasisPoints);
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

    function getChainPrice(uint16 market, bool _maximise) internal view returns (uint256) {
        uint256 xxxUSD = _getChainPrice(market, _maximise);
        uint256 _USDTUSD = _getChainPrice(market, _maximise);
        if (xxxUSD < (2 ** 256 - 1) / PRICE_PRECISION) {
            return (xxxUSD * PRICE_PRECISION) / _USDTUSD;
        }
        return (xxxUSD / PRICE_PRECISION) * _USDTUSD;
    }

    function favorFastPrice(uint16 market) internal view returns (bool) {
        if (Storage().config.isSpreadEnablede) {
            return false;
        }

        (,, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta) = getPriceData(market);
        if (
            cumulativeFastDelta > cumulativeRefDelta
                && cumulativeFastDelta - cumulativeRefDelta > Storage().maxCumulativeDeltaDiffs[market]
        ) {
            // fast > chainlink, fast-chainlink >
            // force a spread if the cumulative delta for the fast price feed exceeds the cumulative delta
            // for the Chainlink price feed by the maxCumulativeDeltaDiff allowed
            return false;
        }

        return true;
    }

    function getPriceData(uint16 market) internal view returns (uint256, uint256, uint256, uint256) {
        PriceDataItem memory data = Storage().priceData[market];
        return (
            uint256(data.refPrice),
            uint256(data.refTime),
            uint256(data.cumulativeRefDelta),
            uint256(data.cumulativeFastDelta)
        );
    }

    function getLatestPrice(uint16 market) internal view returns (uint256) {
        uint256 xxxUSD = _getLatestPrice(market);
        uint256 _USDTUSD = (IPriceFeed(Storage().USDT).latestAnswer()).toUint256();
        if (xxxUSD < (2 ** 256 - 1) / PRICE_PRECISION) {
            return (xxxUSD * PRICE_PRECISION) / _USDTUSD;
        }
        return (xxxUSD / PRICE_PRECISION) * _USDTUSD;
    }

    //==================================================================================================
    //================ private functions================================================================
    //==================================================================================================
    function _getLatestPrice(uint16 market) private view returns (uint256) {
        address _feed = Storage().priceFeeds[market];
        require(_feed != address(0), "PriceFeed: invalid price feed");
        IPriceFeed _priceFeed = IPriceFeed(_feed);
        int256 _price = _priceFeed.latestAnswer();
        require(_price > 0, "PriceFeed: invalid price");
        return uint256(_price);
    }

    function _setPrice(uint16 market, uint256 _price) internal {
        if (market != 0) {
            uint256 refPrice = getLatestPrice(market);
            uint256 fastPrice = Storage().prices[market];

            (uint256 prevRefPrice, uint256 refTime, uint256 cumulativeRefDelta, uint256 cumulativeFastDelta) =
                getPriceData(market);

            if (prevRefPrice > 0) {
                // chainlink
                uint256 refDeltaAmount = refPrice > prevRefPrice ? refPrice - prevRefPrice : prevRefPrice - refPrice;
                // fastPrice
                uint256 fastDeltaAmount = fastPrice > _price ? fastPrice - _price : _price - fastPrice;

                // reset cumulative delta values if it is a new time window
                if (
                    refTime / Storage().config.priceDataInterval != block.timestamp / Storage().config.priceDataInterval
                ) {
                    cumulativeRefDelta = 0;
                    cumulativeFastDelta = 0;
                }
                //
                cumulativeRefDelta = cumulativeRefDelta + (refDeltaAmount * CUMULATIVE_DELTA_PRECISION) / prevRefPrice;
                cumulativeFastDelta = cumulativeFastDelta + (fastDeltaAmount * CUMULATIVE_DELTA_PRECISION) / fastPrice;
            }

            if (
                cumulativeFastDelta > cumulativeRefDelta
                    && cumulativeFastDelta - cumulativeRefDelta > Storage().maxCumulativeDeltaDiffs[market]
            ) {
                emit MaxCumulativeDeltaDiffExceeded(
                    market, refPrice, fastPrice, cumulativeRefDelta, cumulativeFastDelta
                );
            }

            _setPriceData(market, refPrice, cumulativeRefDelta, cumulativeFastDelta);
            emit PriceData(market, refPrice, fastPrice, cumulativeRefDelta, cumulativeFastDelta);
        }

        Storage().prices[market] = _price;
        emit UpdatePrice(msg.sender, market, _price);
    }

    function _setPriceData(uint16 _market, uint256 _refPrice, uint256 _cumulativeRefDelta, uint256 _cumulativeFastDelta)
        private
    {
        require(_refPrice < MAX_REF_PRICE, "FastPriceFeed: invalid refPrice");
        // skip validation of block.timestamp, it should only be out of range after the year 2100
        require(_cumulativeRefDelta < MAX_CUMULATIVE_REF_DELTA, "FastPriceFeed: invalid cumulativeRefDelta");
        require(_cumulativeFastDelta < MAX_CUMULATIVE_FAST_DELTA, "FastPriceFeed: invalid cumulativeFastDelta");

        Storage().priceData[_market] = PriceDataItem(
            uint160(_refPrice), uint32(block.timestamp), uint32(_cumulativeRefDelta), uint32(_cumulativeFastDelta)
        );
    }

    function _getChainPrice(uint16 market, bool _maximise) private view returns (uint256) {
        address _feed = Storage().priceFeeds[market];
        require(_feed != address(0), "PriceFeed: invalid price feed");

        uint256 _price = 0;
        uint80 _id = IPriceFeed(Storage().priceFeeds[market]).latestRound();

        for (uint80 i = 0; i < Storage().config.sampleSpace; i++) {
            if (_id <= i) {
                break;
            }
            uint256 p;

            if (i == 0) {
                int256 _p = IPriceFeed(Storage().priceFeeds[market]).latestAnswer();
                require(_p > 0, "PriceFeed: invalid price");
                p = uint256(_p);
            } else {
                (, int256 _p,,,) = IPriceFeed(Storage().priceFeeds[market]).getRoundData(_id - i);
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
        uint256 _decimals = IPriceFeed(Storage().priceFeeds[market]).decimals();
        return (_price * PRICE_PRECISION) / (10 ** _decimals);
    }

    function _getPrice(uint16 market, bool _maximise) internal view returns (uint256) {
        uint256 price = getChainPrice(market, _maximise);

        if (Storage().config.isFastPriceEnabled) {
            price = getFastPrice(market, price, _maximise);
        }

        uint256 _spreadBasisPoints = Storage().spreadBasisPoints[market];

        if (_maximise) {
            return (price * (BASIS_POINTS_DIVISOR + _spreadBasisPoints)) / BASIS_POINTS_DIVISOR;
        }
        return (price * (BASIS_POINTS_DIVISOR - _spreadBasisPoints)) / BASIS_POINTS_DIVISOR;
    }
}
