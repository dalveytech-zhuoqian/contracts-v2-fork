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

        assertEq(remaining, 0, "Remaining should be 0 when size is greater than or equal to limit");

        size = 3;
        limit = 5;

        remaining = GValidHandler.calRemaining(size, limit);

        assertEq(remaining, 2, "Remaining should be the difference between limit and size");
    }

    function testGetMaxUseableMarketSize() public {
        uint16 market = 123;
        bool isLong = true;
        uint256 limit = 10;
        uint256 longSize = 10;
        uint256 shortSize = 5;

        GValidHandler.setMaxMarketSizeLimit(market, limit);

        uint256 maxUseableMarketSize = GValidHandler._getMaxUseableMarketSize(market, isLong, longSize, shortSize);

        assertEq(
            maxUseableMarketSize, 0, "Max useable market size should be 0 when size is greater than or equal to limit"
        );

        isLong = false;
        longSize = 3;
        shortSize = 6;

        maxUseableMarketSize = GValidHandler._getMaxUseableMarketSize(market, isLong, longSize, shortSize);

        assertEq(maxUseableMarketSize, 4, "Max useable market size should be the difference between limit and size");
    }
}
