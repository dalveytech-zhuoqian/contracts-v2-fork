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

    function testGetFeesReceivable() public {
        // Create a mock MarketCache object
        MarketCache memory params;
        params.market = 1;
        params.sizeDelta = 100;
        params.collateralDelta = 0;
        params.isOpen = true;
        params.liqState = LiquidationState.None;
        params.execNum = 2;

        // Set the feeAndRates values
        FeeHandler.FeeStorage storage feeStorage = FeeHandler.Storage();
        feeStorage.feeAndRates[params.market][uint8(FeeType.OpenFee)] = 5000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.CloseFee)] = 6000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.LiqFee)] = 7000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.ExecFee)] = 8000;

        // Call the _getFeesReceivable function
        int256[] memory fees = FeeHandler._getFeesReceivable(params, 100);

        // Assert the expected fees
        assertEq(fees[uint8(FeeType.FundFee)], 100, "FundFee should be 100");
        assertEq(fees[uint8(FeeType.OpenFee)], 50, "OpenFee should be 50");
        assertEq(fees[uint8(FeeType.LiqFee)], 0, "LiqFee should be 0");
        assertEq(fees[uint8(FeeType.ExecFee)], 16000, "ExecFee should be 16000");

        params.isOpen = false;
        fees = FeeHandler._getFeesReceivable(params, 100);
        assertEq(fees[uint8(FeeType.CloseFee)], 60, "CloseFee should be 60");
    }

    function testGetOrderFees() public {
        // Create a sample MarketDataTypes.UpdateOrderInputs struct
        MarketCache memory params;
        params.isOpen = true;
        params.market = 1;
        params.sizeDelta = 100;

        FeeHandler.FeeStorage storage feeStorage = FeeHandler.Storage();
        feeStorage.feeAndRates[params.market][uint8(FeeType.OpenFee)] = 5000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.CloseFee)] = 6000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.LiqFee)] = 7000;
        feeStorage.feeAndRates[params.market][uint8(FeeType.ExecFee)] = 8000;

        // Call the getOrderFees function
        int256 fees = FeeHandler.getOrderFees(params);

        // Assert the expected fees value
        assertEq(fees, 8050);

        params.isOpen = false;

        // Call the getOrderFees function
        fees = FeeHandler.getOrderFees(params);

        // Assert the expected fees value
        assertEq(fees, 8060);
    }
}
