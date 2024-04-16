// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/order/OrderHandler.sol";
import "src/lib/order/OrderHelper.sol";
import "src/lib/types/Types.sol";

contract OrderHandlerTest is Test {
    using OrderHelper for OrderProps;
    using OrderHandler for bytes32;

    function testOrderHandler() public {
        bytes32 storageKey = OrderHelper.storageKey(0, true, true);
        address account = address(0x0123456789abcdef);
        OrderProps memory order;
        order.account = account;
        order.price = 100;
        order.size = 10;
        order.updatedAtBlock = uint32(block.number);

        // Test add function
        OrderHandler.add(storageKey, order);
        assertTrue(OrderHandler.containsKey(storageKey, order.getKey()), "Order should be added");

        // Test getOrderByIndex function
        OrderProps memory retrievedOrder = OrderHandler.getOrderByIndex(0, true, true, 0);
        assertTrue(retrievedOrder.account == account, "Retrieved order account should match");

        // Test getOrderCount function
        uint256 orderCount = OrderHandler.getOrderCount(0, true, true);
        assertTrue(orderCount == 1, "Order count should be 1");

        // Test remove function
        OrderProps memory removedOrder = OrderHandler.remove(storageKey, order.getKey());
        assertTrue(removedOrder.account == account, "Removed order account should match");
        assertTrue(!OrderHandler.containsKey(storageKey, order.getKey()), "Order should be removed");
    }
}
