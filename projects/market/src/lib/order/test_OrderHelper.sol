// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/order/OrderHelper.sol";
import "src/lib/types/Types.sol";

contract CompilationTest is Test {
    using OrderHelper for OrderProps;

    function testGetKey() public {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        bytes32 expectedKey = keccak256(abi.encodePacked(order.account, order.orderID));
        bytes32 actualKey = order.getKey();

        assertEq(actualKey, expectedKey, "Incorrect key generated");
    }

    function testUpdateTime() public {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        uint32 expectedUpdatedAtBlock = uint32(block.timestamp);
        order.updateTime();

        assertEq(order.updatedAtBlock, expectedUpdatedAtBlock, "Incorrect updatedAtBlock value");
    }

    function testStorageKey() public pure {
        bytes32 expectedStorageKey = bytes32(abi.encode(true, true, 123));
        bytes32 actualStorageKey = OrderHelper.storageKey(123, true, true);

        assertEq(actualStorageKey, expectedStorageKey, "Incorrect storage key generated");
    }

    function testGetPairKey() public view {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        bytes32 expectedPairKey = keccak256(abi.encodePacked(order.account, order.pairId));
        bytes32 actualPairKey = order.getPairKey();

        assertEq(actualPairKey, expectedPairKey, "Incorrect pair key generated");
    }

    function testIsMarkPriceValid() public view {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        uint256 oraclePrice = 150;
        bool expectedValidity = oraclePrice >= uint256(order.price);
        bool actualValidity = order.isMarkPriceValid(oraclePrice);

        assertEq(actualValidity, expectedValidity, "Incorrect mark price validity");
    }
}
