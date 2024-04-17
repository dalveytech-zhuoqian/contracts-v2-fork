// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/market/MarketHandler.sol";

contract MarketHandlerTest is Test {
    function testGetDecreaseOrderValidation() public {
        MarketHandler.StorageStruct storage fs = MarketHandler.Storage();
        fs.config[1].decreaseNumLimit = 10;
        uint16 market = 1;
        uint256 decrOrderCount = 5;

        bool isValid = MarketHandler.getDecreaseOrderValidation(
            market,
            decrOrderCount
        );
        assertEq(
            isValid,
            true,
            "Validation should be true when decrOrderCount is within limit"
        );

        decrOrderCount = 12;
        isValid = MarketHandler.getDecreaseOrderValidation(
            market,
            decrOrderCount
        );
        assertEq(
            isValid,
            false,
            "Validation should be false when decrOrderCount exceeds limit"
        );
    }
}
