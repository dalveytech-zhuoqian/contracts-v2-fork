// 1. 外部预言机的依赖
// 2. 处理预言机精度
// 3. 价格逻辑的方法

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";
import {IPrice} from "../interfaces/IPrice.sol";
import "hardhat-deploy/solc_0.8/diamond/UsingDiamondOwner.sol";

contract OracleFacet is IAccessManaged, IPrice, UsingDiamondOwner {
    //================================================================
    //   ADMIN functions
    //================================================================

    function initDefaultOracleConfig() external onlyOwner {
        OracleHandler.ConfigStruct memory _config = OracleHandler.ConfigStruct({
            maxDeviationBP: 100, //超过 1% 进行比价
            priceDuration: 300, //checked
            maxPriceUpdateDelay: 3600, // checked
            priceDataInterval: 60, //checked
            sampleSpace: 1 //checked
        });
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.config = _config;
    }

    function setOracleConfig(
        OracleHandler.ConfigStruct memory _config
    ) external restricted {
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.config = _config;
    }

    function setPrices(
        uint16[] memory _markets,
        uint256[] memory _prices
    ) external restricted {
        OracleHandler.setPrices(_markets, _prices);
    }

    function setMaxCumulativeDeltaDiffs(
        uint16[] memory _market,
        uint256[] memory _maxCumulativeDeltaDiffs
    ) external restricted {
        for (uint256 i = 0; i < _market.length; i++) {
            OracleHandler.Storage().maxCumulativeDeltaDiffs[
                _market[i]
            ] = _maxCumulativeDeltaDiffs[i];
        }
    }

    function setUSDT(address _feed) external restricted {
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.USDT = _feed;
    }

    //========================================================================
    //     view functions
    //========================================================================

    function priceFeed(uint16 market) external view returns (address) {
        return OracleHandler.Storage().priceFeeds[market];
    }

    function usdtFeed() external view returns (address) {
        return OracleHandler.Storage().USDT;
    }

    function getPrice(
        uint16 market,
        bool _maximise
    ) external view override returns (uint256) {
        return OracleHandler.getPrice(market, _maximise);
    }

    function getChainPrice(
        uint16 market,
        bool _maximise
    ) external view returns (uint256) {
        return OracleHandler.getChainPrice(market, _maximise);
    }

    function getFastPrice(
        uint16 market,
        uint256 _referencePrice,
        bool _maximise
    ) external view returns (uint256) {
        return OracleHandler.getFastPrice(market, _referencePrice, _maximise);
    }
}
