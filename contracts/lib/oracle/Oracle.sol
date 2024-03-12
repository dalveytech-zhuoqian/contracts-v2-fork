// 1. 外部预言机的依赖
// 2. 处理预言机精度
// 3. 价格逻辑的方法

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibAccessManaged} from "../ac/LibAccessManaged.sol";

contract Oracle {
    function setPrices(address[] memory _tokens, uint256[] memory _prices, uint256 _timestamp) external restricted {}
    function setPricesAndExecute(bytes calldata _data) external stricted {}
    function setAdjustment(address _token, bool _isAdditive, uint256 _adjustmentBps) external restricted {}

    function setFastPriceEnabled(bool _isEnabled) external restricted {}

    function setIsGmxPriceEnabled(bool enable) external restricted {}

    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints) external restricted {}

    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints) external restricted {}

    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation) external restricted {}

    function setStableTokens(address _token, bool _stable) external restricted {}
    function setMaxTimeDeviation(uint256 _deviation) external restricted {}

    function setPriceDuration(uint256 _duration) external restricted {}

    function setMaxPriceUpdateDelay(uint256 _delay) external restricted {}

    function setSpreadBasisPointsIfInactive(uint256 _point) external restricted {}

    function setSpreadBasisPointsIfChainError(uint256 _point) external restricted {}

    function setMinBlockInterval(uint256 _interval) external restricted {}

    function setIsSpreadEnabled(bool _enabled) external restricted {}

    function setLastUpdatedAt(uint256 _lastUpdatedAt) external restricted {}

    function setMaxDeviationBasisPoints(uint256 _maxDeviationBasisPoints) external restricted {}
    function setMaxCumulativeDeltaDiffs(address[] memory _tokens, uint256[] memory _maxCumulativeDeltaDiffs)
        external
        restricted
    {}

    function setPriceDataInterval(uint256 _priceDataInterval) external restricted {}
    function setTokens(address[] memory _tokens, uint256[] memory _tokenPrecisions) external restricted {}
    function setSampleSpace(uint256 _times) external restricted {}
    function setUSDT(address _token, address _feed, uint256 _decimal) external restricted {}

    //========================================================================
    //     view functions
    //========================================================================

    function getPrice(address _token, bool _maximise) public view returns (uint256) {}

    function getChainPrice(address _token, bool _maximise) public view returns (uint256) {}

    function getFastPrice(address _token, uint256 _referencePrice, bool _maximise) public view returns (uint256) {}

    function getGmxPrice(address _token, bool _maximise) public view returns (uint256) {}

    //========================================================================
    //     private functions
    //========================================================================
    function _getPrice(address _token, bool _maximise) private view returns (uint256) {}
}
