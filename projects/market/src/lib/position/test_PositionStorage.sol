// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/position/PositionStorage.sol";
import "src/lib/types/Types.sol";

contract PositionStorageTest is Test {
    using PositionStorage for PositionCache;

    function testRemove() public {
        // Create a sample PositionCache object
        PositionCache memory cache;
        cache.account = address(0x123);
        cache.market = 2;
        cache.isLong = true;

        // todo

        // Add a position to the storage
        // PositionStorage.Storage().positions[cache.sk][cache.account] = PositionStorage.PositionProps({
        //     market: cache.market,
        //     isLong: cache.isLong,
        //     size: cache.sizeDelta,
        //     // Add other properties here
        // });
        // PositionStorage.Storage().positionKeys[cache.sk].add(cache.account);

        // // Call the remove function
        // PositionStorage.remove(cache);

        // // Assert that the position is removed from the storage
        // assertEq(PositionStorage.Storage().positions[cache.sk][cache.account].market, 0, "Position should be removed");
        // assertEq(PositionStorage.Storage().positionKeys[cache.sk].contains(cache.account), false, "Position key should be removed");

        // Assert that the events are emitted correctly
        // Add assertions for emitted events here
    }
}
