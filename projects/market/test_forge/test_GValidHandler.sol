// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/globalValid/GValidHandler.sol";
import "src/lib/types/Types.sol";

contract GValidHandlerTest is Test {
    function testCalRemaining() public {
        uint256 size = 10;
        uint256 limit = 5;

        uint256 remaining = GValidHandler.calRemaining(size, limit);

        assertEq(
            remaining,
            0,
            "Remaining should be 0 when size is greater than or equal to limit"
        );

        size = 3;
        limit = 5;

        remaining = GValidHandler.calRemaining(size, limit);

        assertEq(
            remaining,
            2,
            "Remaining should be the difference between limit and size"
        );
    }

    function testGetMaxUseableMarketSize() public {
        uint16 market = 123;
        bool isLong = true;
        uint256 limit = 10;
        uint256 longSize = 10;
        uint256 shortSize = 5;

        GValidHandler.setMaxMarketSizeLimit(market, limit);

        uint256 maxUseableMarketSize = GValidHandler._getMaxUseableMarketSize(
            market,
            isLong,
            longSize,
            shortSize
        );

        assertEq(
            maxUseableMarketSize,
            0,
            "Max useable market size should be 0 when size is greater than or equal to limit"
        );

        isLong = false;
        longSize = 3;
        shortSize = 6;

        maxUseableMarketSize = GValidHandler._getMaxUseableMarketSize(
            market,
            isLong,
            longSize,
            shortSize
        );

        assertEq(
            maxUseableMarketSize,
            4,
            "Max useable market size should be the difference between limit and size"
        );
    }

    function testGetMaxUseableUserNetSize() public {
        uint256 longSize = 10;
        uint256 shortSize = 5;
        uint256 aum = 1000;
        bool isLong = true;

        uint256 maxUseableUserNetSize = GValidHandler._getMaxUseableUserNetSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableUserNetSize,
            995,
            "Max useable user net size should be 0 when size is greater than or equal to limit"
        );

        isLong = false;
        longSize = 3;
        shortSize = 6;

        maxUseableUserNetSize = GValidHandler._getMaxUseableUserNetSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableUserNetSize,
            997,
            "Max useable user net size should be the difference between limit and size"
        );
    }

    function testGetMaxUseableNetSize() public {
        uint256 longSize = 10;
        uint256 shortSize = 5;
        uint256 aum = 1000;
        bool isLong = true;

        uint256 maxUseableNetSize = GValidHandler._getMaxUseableNetSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableNetSize,
            995,
            "Max useable net size should be 0 when size is greater than or equal to limit"
        );

        isLong = false;
        longSize = 3;
        shortSize = 6;

        maxUseableNetSize = GValidHandler._getMaxUseableNetSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableNetSize,
            997,
            "Max useable net size should be the difference between limit and size"
        );
    }

    function testGetMaxUseableGlobalSize() public {
        uint256 longSize = 10;
        uint256 shortSize = 5;
        uint256 aum = 1000;
        bool isLong = true;

        GValidHandler.setMaxSizeLimit(100); // Set the maxSizeLimit to 100 for testing purposes

        uint256 maxUseableGlobalSize = GValidHandler._getMaxUseableGlobalSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableGlobalSize,
            0,
            "Max useable global size should be 0 when size is greater than or equal to limit"
        );

        isLong = false;
        longSize = 3;
        shortSize = 6;

        maxUseableGlobalSize = GValidHandler._getMaxUseableGlobalSize(
            longSize,
            shortSize,
            aum,
            isLong
        );

        assertEq(
            maxUseableGlobalSize,
            4,
            "Max useable global size should be the difference between limit and size"
        );
    }

    function testGetMaxIncreasePositionSize() public {
        GValid memory params;

        // Test case 1: All sizes are greater than or equal to limit
        params.globalLongSizes = 10;
        params.globalShortSizes = 5;
        params.aum = 1000;
        params.isLong = true;
        params.userLongSizes = 10;
        params.userShortSizes = 5;
        params.market = 123;
        params.marketLongSizes = 10;
        params.marketShortSizes = 5;

        uint256 maxIncreasePositionSize = GValidHandler
            .getMaxIncreasePositionSize(params);

        assertEq(
            maxIncreasePositionSize,
            990,
            "Max increase in position size should be 0 when all sizes are greater than or equal to limit"
        );

        // Test case 2: Only global sizes are less than limit
        params.globalLongSizes = 3;
        params.globalShortSizes = 6;
        params.aum = 1000;
        params.isLong = true;
        params.userLongSizes = 10;
        params.userShortSizes = 5;
        params.market = 123;
        params.marketLongSizes = 10;
        params.marketShortSizes = 5;

        maxIncreasePositionSize = GValidHandler.getMaxIncreasePositionSize(
            params
        );

        assertEq(
            maxIncreasePositionSize,
            995,
            "Max increase in position size should be the minimum of all sizes"
        );

        // Test case 3: Only user net sizes are less than limit
        params.globalLongSizes = 10;
        params.globalShortSizes = 5;
        params.aum = 1000;
        params.isLong = true;
        params.userLongSizes = 3;
        params.userShortSizes = 6;
        params.market = 123;
        params.marketLongSizes = 10;
        params.marketShortSizes = 5;

        maxIncreasePositionSize = GValidHandler.getMaxIncreasePositionSize(
            params
        );

        assertEq(
            maxIncreasePositionSize,
            990,
            "Max increase in position size should be the minimum of all sizes"
        );

        // Test case 4: Only market size is less than limit
        params.globalLongSizes = 10;
        params.globalShortSizes = 5;
        params.aum = 1000;
        params.isLong = true;
        params.userLongSizes = 10;
        params.userShortSizes = 5;
        params.market = 123;
        params.marketLongSizes = 3;
        params.marketShortSizes = 6;

        maxIncreasePositionSize = GValidHandler.getMaxIncreasePositionSize(
            params
        );

        assertEq(
            maxIncreasePositionSize,
            990,
            "Max increase in position size should be the minimum of all sizes"
        );

        // Test case 5: All sizes are less than limit
        params.globalLongSizes = 3;
        params.globalShortSizes = 6;
        params.aum = 1000;
        params.isLong = true;
        params.userLongSizes = 3;
        params.userShortSizes = 6;
        params.market = 123;
        params.marketLongSizes = 3;
        params.marketShortSizes = 6;

        maxIncreasePositionSize = GValidHandler.getMaxIncreasePositionSize(
            params
        );

        assertEq(
            maxIncreasePositionSize,
            997,
            "Max increase in position size should be the minimum of all sizes"
        );
    }
}
