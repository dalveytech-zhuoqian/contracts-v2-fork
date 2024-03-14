// 1. 外部预言机的依赖
// 2. 处理预言机精度
// 3. 价格逻辑的方法

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "./lib/ac/LibAccessManaged.sol";
import {LibOracleStore} from "./lib/oracle/LibOracleStore.sol";

contract OracleFacet {
    function setConfig(LibOracleStore.ConfigStruct calldata _config) external {
        LibOracleStore.StorageStruct storage store = LibOracleStore.getStorage();
        store.config = _config;
    }

    function setPrices(address[] memory _tokens, uint256[] memory _prices, uint256 _timestamp) external restricted {}
    function setPricesAndExecute(bytes calldata _data) external stricted {}
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external restricted {}

    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external restricted {}

    function setStableTokens(address _token, bool _stable) external restricted {}

    function setMaxCumulativeDeltaDiffs(address[] memory _tokens, uint256[] memory _maxCumulativeDeltaDiffs)
        external
        restricted
    {}

    function setTokens(address[] memory _tokens, uint256[] memory _tokenPrecisions) external restricted {}

    function setUSDT(address _token, address _feed, uint256 _decimal) external restricted {}

    //========================================================================
    //     view functions
    //========================================================================

    function getPrice(address _token, bool _maximise) public view returns (uint256) {}

    function getChainPrice(address _token, bool _maximise) public view returns (uint256) {}

    function getFastPrice(address _token, uint256 _referencePrice, bool _maximise) public view returns (uint256) {}
}
