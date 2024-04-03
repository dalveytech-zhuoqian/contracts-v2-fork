// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "src/lib/globalvalid/GValidHandler.sol";

contract GValidHandlerTest is Test {
    function setUp() public {}

    function testSetMaxSizeLimit() public {
        uint256 testLimit = 16;
        vm.assume(testLimit > 0);
        // set should revert if limit is 0
        GValidHandler.setMaxSizeLimit(testLimit);
        assertEq(GValidHandler.maxSizeLimit(), testLimit, "not equal");
    }

    function testFailSetMaxSizeLimitZero() public {
        GValidHandler.setMaxSizeLimit(0);
    }
}
