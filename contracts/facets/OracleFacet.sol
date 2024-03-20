// 1. 外部预言机的依赖
// 2. 处理预言机精度
// 3. 价格逻辑的方法

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";

contract OracleFacet is IAccessManaged {
    function initDefaultOracleConfig() external restricted {
        OracleHandler.ConfigStruct memory _config = OracleHandler.ConfigStruct({
            isSpreadEnablede: true,
            isFastPriceEnabled: true,
            maxDeviationBasisPoints: 1000,
            priceDuration: 300,
            maxPriceUpdateDelay: 3600,
            spreadBasisPointsIfInactive: 100,
            spreadBasisPointsIfChainError: 100,
            priceDataInterval: 100,
            sampleSpace: 3
        });
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.config = _config;
    }

    function setConfig(bytes calldata _data) external restricted {
        (OracleHandler.ConfigStruct memory _config) = abi.decode(_data, (OracleHandler.ConfigStruct));
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.config = _config;
    }

    function setPrices(uint16[] memory _markets, uint256[] memory _prices) external restricted {
        OracleHandler.setPrices(_markets, _prices);
    }

    function setMaxCumulativeDeltaDiffs(uint16[] memory _market, uint256[] memory _maxCumulativeDeltaDiffs)
        external
        restricted
    {
        for (uint256 i = 0; i < _market.length; i++) {
            OracleHandler.Storage().maxCumulativeDeltaDiffs[_market[i]] = _maxCumulativeDeltaDiffs[i];
        }
    }

    function setUSDT(address _feed) external restricted {
        OracleHandler.StorageStruct storage store = OracleHandler.Storage();
        store.USDT = _feed;
    }

    //========================================================================
    //     view functions
    //========================================================================

    function getPrice(uint16 market, bool _maximise) external view returns (uint256) {
        return OracleHandler.getPrice(market, _maximise);
    }

    function getChainPrice(uint16 market, bool _maximise) external view returns (uint256) {
        return OracleHandler.getChainPrice(market, _maximise);
    }

    function getFastPrice(uint16 market, uint256 _referencePrice, bool _maximise) external view returns (uint256) {
        return OracleHandler.getFastPrice(market, _referencePrice, _maximise);
    }
}
