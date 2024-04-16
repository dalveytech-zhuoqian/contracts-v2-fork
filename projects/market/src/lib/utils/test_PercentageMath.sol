// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/utils/PercentageMath.sol";

contract PercentageMathTest is Test {
    using PercentageMath for uint256;

    function testMaxPctIfZero() public {
        uint256 result = PercentageMath.maxPctIfZero(0);
        assertEq(
            result,
            1e4,
            "Should return PERCENTAGE_FACTOR when input is 0"
        );

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

    function testPercentMul() public {
        uint256 value = 100;
        uint256 percentage = 0.5e4;
        uint256 expected = 50;
        uint256 result = PercentageMath.percentMul(value, percentage);
        assertEq(
            result,
            expected,
            "Incorrect percentage multiplication result"
        );

        value = 200;
        percentage = 0.75e4;
        expected = 150;
        result = PercentageMath.percentMul(value, percentage);
        assertEq(
            result,
            expected,
            "Incorrect percentage multiplication result"
        );

        value = 0;
        percentage = 1e4;
        expected = 0;
        result = PercentageMath.percentMul(value, percentage);
        assertEq(
            result,
            expected,
            "Incorrect percentage multiplication result"
        );
    }

    function testPercentDiv() public {
        uint256 value = 100;
        uint256 percentage = 0.5e4;
        uint256 expected = 200;
        uint256 result = PercentageMath.percentDiv(value, percentage);
        assertEq(result, expected, "Incorrect percentage division result");

        value = 200;
        percentage = 0.2e4;
        expected = 1000;
        result = PercentageMath.percentDiv(value, percentage);
        assertEq(result, expected, "Incorrect percentage division result");

        value = 0;
        percentage = 1e4;
        expected = 0;
        result = PercentageMath.percentDiv(value, percentage);
        assertEq(result, expected, "Incorrect percentage division result");
    }
}
