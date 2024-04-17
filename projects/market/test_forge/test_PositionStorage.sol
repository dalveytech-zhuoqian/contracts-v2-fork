// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/position/PositionStorage.sol";
import "src/lib/types/Types.sol";

contract PositionStorageTest is Test {
    using PositionStorage for PositionCache;

    function testCalPNL() public {
        PositionProps memory position;
        position.size = 20;
        position.averagePrice = 100;
        position.isLong = true;
        // Call the _calPNL function and assert the returned value
        int256 result = PositionStorage._calPNL(position, 5, 150);
        assertEq(result, 750);
    }
}
