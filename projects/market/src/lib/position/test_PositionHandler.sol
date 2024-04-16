// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/position/PositionHandler.sol";

contract PositionHandlerTest is Test {
    function testCalGlobalPosition() public {
        PositionCache memory cache;
        cache.isOpen = true;
        cache.sizeDelta = 10;
        cache.markPrice = 200;
        cache.collateralDelta = 100;
        cache.isLong = true;

        PositionProps memory position;
        position.averagePrice = 150;
        position.size = 20;
        position.collateral = 500;
        position.isLong = true;
        position.lastTime = 0;

        PositionProps memory expectedPosition;
        expectedPosition.averagePrice = 200;
        expectedPosition.size = 30;
        expectedPosition.collateral = 600;
        expectedPosition.isLong = true;
        expectedPosition.lastTime = uint32(block.timestamp);

        PositionProps memory calculatedPosition = PositionHandler._calGlobalPosition(cache);

        assertEq(calculatedPosition.averagePrice, expectedPosition.averagePrice, "Incorrect average price");
        assertEq(calculatedPosition.size, expectedPosition.size, "Incorrect size");
        assertEq(calculatedPosition.collateral, expectedPosition.collateral, "Incorrect collateral");
        assertEq(calculatedPosition.isLong, expectedPosition.isLong, "Incorrect isLong");
        assertEq(calculatedPosition.lastTime, expectedPosition.lastTime, "Incorrect lastTime");
    }

    function testCalGlobalAveragePrice() public {
        PositionProps memory position;
        position.size = 20;

        uint256 sizeDelta = 10;
        uint256 markPrice = 200;

        uint256 expectedAveragePrice = 175;

        uint256 calculatedAveragePrice = PositionHandler._calGlobalAveragePrice(position, sizeDelta, markPrice);

        assertEq(calculatedAveragePrice, expectedAveragePrice, "Incorrect average price");
    }
}
