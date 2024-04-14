// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/lib/fee/FeeHandler.sol";
import "src/lib/types/Types.sol";

contract FeeHandlerTest is Test {
    using FeeHandler for FeeHandler.FeeStorage;

    function setUp() public {
        FeeHandler.initialize(1);
    }

    function testInitialize() public {
        FeeHandler.FeeStorage storage feeStorage = FeeHandler.Storage();

        assertEq(
            feeStorage.configs[1][uint8(FeeHandler.ConfigType.MaxFRatePerDay)],
            10000,
            "MaxFRatePerDay should be initialized to 10000"
        );
        assertEq(
            feeStorage.configs[1][uint8(FeeHandler.ConfigType.FRateFactor)],
            10000,
            "FRateFactor should be initialized to 10000"
        );
        assertEq(
            feeStorage.configs[1][uint8(FeeHandler.ConfigType.MinFRate)], 1250, "MinFRate should be initialized to 1250"
        );
        assertEq(
            feeStorage.configs[1][uint8(FeeHandler.ConfigType.MinFundingInterval)],
            3600,
            "MinFundingInterval should be initialized to 3600"
        );
        assertEq(
            feeStorage.configs[1][uint8(FeeHandler.ConfigType.FundingFeeLossOffLimit)],
            1000000,
            "FundingFeeLossOffLimit should be initialized to 1000000"
        );
    }

    function testGetFeeOfKind() public {
        FeeHandler.FeeStorage storage feeStorage = FeeHandler.Storage();

        uint16 market = 1;
        uint256 sizeDelta = 0;
        uint8 kind = uint8(FeeType.OpenFee);

        uint256 fee = FeeHandler.getFeeOfKind(market, sizeDelta, kind);

        assertEq(fee, 0, "Fee should be 0 when sizeDelta is 0");

        sizeDelta = 100;

        feeStorage.feeAndRates[market][kind] = 5000;

        fee = FeeHandler.getFeeOfKind(market, sizeDelta, kind);

        assertEq(fee, sizeDelta * 5000 / 10000, "Fee should be 5000 when sizeDelta is not 0");
    }

    // Add more test cases for other functions in the FeeHandler library
}
