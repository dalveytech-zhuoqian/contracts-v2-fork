// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/oracle/OracleHandler.sol";

contract OracleHandlerTest is Test {
    function testIsFastPriceFavored() public {
        uint256 cumulativeRefDelta = 100;
        uint256 cumulativeFastDelta = 200;
        uint256 maxCumulativeDeltaDiffs = 50;

        bool result = OracleHandler.isFastPriceFavored(cumulativeRefDelta, cumulativeFastDelta, maxCumulativeDeltaDiffs);

        assertTrue(result, "Fast price should be favored");
    }

    function testComparePrices() public {
        uint256 price1 = 100;
        uint256 price2 = 200;
        bool maximize = true;

        uint256 result = OracleHandler.comparePrices(price1, price2, maximize);

        assertEq(result, price2, "Incorrect comparison result");
    }

    function testGetFastPrice() public {
        uint16 market = 1;
        uint256 refPrice = 100;
        bool maximize = true;

        // Set up test data
        OracleHandler.Storage().priceData[market].refTime = uint32(block.timestamp);
        OracleHandler.Storage().prices[market] = 150;
        OracleHandler.Storage().config.maxPriceUpdateDelay = 3600;
        OracleHandler.Storage().config.priceDuration = 86400;
        OracleHandler.Storage().config.maxDeviationBP = 100;

        // Call the function under test
        uint256 result = OracleHandler.getFastPrice(market, refPrice, maximize);

        // Perform assertions
        assertEq(result, 150, "Incorrect fast price");
    }

    function testGetChainPrice() public {
        uint16 market = 1;
        bool maximize = true;

        // Mock price feed
        IPriceFeedMock priceFeed = new IPriceFeedMock();
        priceFeed.setLatestRound(5);
        priceFeed.setLatestAnswer(100);
        priceFeed.setRoundData(4, 90);
        priceFeed.setRoundData(3, 110);
        priceFeed.setRoundData(2, 80);
        priceFeed.setRoundData(1, 120);
        priceFeed.setRoundData(0, 70);

        // Set up test data
        OracleHandler.Storage().priceFeeds[market] = address(priceFeed);
        OracleHandler.Storage().config.sampleSpace = 5;

        // Call the function under test
        uint256 result = OracleHandler._getChainPrice(market, maximize);

        // Perform assertions
        assertEq(result, 120 * OracleHandler.PRICE_PRECISION, "Incorrect chain price");
    }
}

contract IPriceFeedMock {
    uint80 public latestRound;
    int256 public latestAnswer;
    mapping(uint80 => int256) public roundData;

    function setLatestRound(uint80 _latestRound) external {
        latestRound = _latestRound;
    }

    function setLatestAnswer(int256 _latestAnswer) external {
        latestAnswer = _latestAnswer;
    }

    function setRoundData(uint80 _roundId, int256 _answer) external {
        roundData[_roundId] = _answer;
    }

    function decimals() external pure returns (uint256) {
        return 18;
    }

    function getRoundData(uint80 _roundId) external view returns (uint80, int256, uint256, uint256, uint80) {
        return (_roundId, roundData[_roundId], 0, 0, 0);
    }
}
