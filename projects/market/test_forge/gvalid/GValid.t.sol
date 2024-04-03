// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/console2.sol";
import "src/lib/globalvalid/GValidHandler.sol";

contract GValidHandlerTest is Test {
    function setUp() public {}

    function testSetMaxSizeLimit(uint256 testLimit) public {
        vm.assume(testLimit > 0);
        vm.assume(testLimit < GValidHandler.BASIS_POINTS_DIVISOR);
        GValidHandler.setMaxSizeLimit(testLimit);
        assertEq(GValidHandler.maxSizeLimit(), testLimit, "not equal");
    }

    function testFailSetMaxSizeLimitZero() public {
        // set should revert if limit is 0
        GValidHandler.setMaxSizeLimit(0);
    }
}
