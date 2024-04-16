// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/order/OrderHelper.sol";
import "src/lib/types/Types.sol";

contract CompilationTest is Test {
    using OrderHelper for OrderProps;

    /**
     * @dev This function is used to test the `getKey` function of the `OrderProps` struct.
     * It creates an instance of the `OrderProps` struct and sets its properties.
     * Then it calculates the expected key using the `keccak256` function and compares it with the actual key returned by the `getKey` function.
     * If the actual key matches the expected key, the test passes. Otherwise, it fails.
     */
    function testGetKey() public view {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        bytes32 expectedKey = keccak256(
            abi.encode(order.account, order.orderID)
        );
        bytes32 actualKey = order.getKey();

        assertEq(actualKey, expectedKey, "Incorrect key generated");
    }

    /**
     * @dev Function to test the updateTime function of the OrderHelper contract.
     * It creates an OrderProps struct and sets its properties.
     * Then, it calls the updateTime function and asserts that the updatedAtBlock value is updated correctly.
     */
    function testUpdateTime() public view {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        uint32 expectedUpdatedAtBlock = uint32(block.timestamp);
        order.updateTime();

        assertEq(
            order.updatedAtBlock,
            expectedUpdatedAtBlock,
            "Incorrect updatedAtBlock value"
        );
    }
    /**
     * @dev Test function to verify the generation of a storage key using the OrderHelper library.
     * It compares the expected storage key with the actual storage key generated and asserts their equality.
     */

    function testStorageKey() public pure {
        bytes32 expectedStorageKey = bytes32(abi.encode(true, true, 123));
        bytes32 actualStorageKey = OrderHelper.storageKey(123, true, true);

        assertEq(
            actualStorageKey,
            expectedStorageKey,
            "Incorrect storage key generated"
        );
    }

    /**
     * @dev Test function to verify the correctness of the `getPairKey` function.
     * It creates an `OrderProps` struct with sample values and compares the generated pair key with the expected pair key.
     */
    function testGetPairKey() public view {
        OrderProps memory order;
        order.account = address(0x123);
        order.orderID = 1;
        order.pairId = 2;
        order.price = 100;
        order.triggerAbove = true;
        order.updatedAtBlock = uint32(block.number);

        bytes32 expectedPairKey = keccak256(
            abi.encode(order.account, order.pairId)
        );
        bytes32 actualPairKey = order.getPairKey();

        assertEq(
            actualPairKey,
            expectedPairKey,
            "Incorrect pair key generated"
        );
    }

    /**
     * @dev Function to test the validity of the mark price for an order.
     * @notice This function creates an `OrderProps` struct and sets its properties.
     * It then compares the mark price with the order price and returns the validity result.
     */
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

        assertEq(
            actualValidity,
            expectedValidity,
            "Incorrect mark price validity"
        );
    }
}
