// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/utils/PercentageMath.sol";

contract PercentageMathTest is Test {
    using PercentageMath for uint256;

    function testMaxPctIfZero() public {
        uint256 result = PercentageMath.maxPctIfZero(0);
        assertEq(result, 1e4, "Should return PERCENTAGE_FACTOR when input is 0");

        result = PercentageMath.maxPctIfZero(100);
        assertEq(result, 100, "Should return the input value when it is not 0");
    }

    function testValid() public {
        PercentageMath.valid(1e4);
    }

    function testFailValidZero() public {
        PercentageMath.valid(0);
    }

    function testFailValidMax() public {
        PercentageMath.valid(1e4 + 1);
    }
}
