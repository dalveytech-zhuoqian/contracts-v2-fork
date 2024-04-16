// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

//================================================================
//handlers
import {MarketHandler} from "../lib/market/MarketHandler.sol";

//================================================================
//interfaces
import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract MarketMakerFacet is IAccessManaged {
    function marketMakerForConfig(
        bool isSuspended,
        bool allowOpen,
        bool allowClose,
        bool validDecrease,
        uint16 minSlippage,
        uint16 maxSlippage,
        uint16 minLeverage,
        uint16 maxLeverage,
        uint16 minPayment,
        uint16 minCollateral,
        uint16 decreaseNumLimit, //default: 10
        uint32 maxTradeAmount
    ) external pure returns (MarketHandler.Props memory) {
        return
            MarketHandler.Props({
                isSuspended: isSuspended,
                allowOpen: allowOpen,
                allowClose: allowClose,
                validDecrease: validDecrease,
                minSlippage: minSlippage,
                maxSlippage: maxSlippage,
                minLeverage: minLeverage,
                maxLeverage: maxLeverage,
                minPayment: minPayment,
                minCollateral: minCollateral,
                decreaseNumLimit: decreaseNumLimit,
                maxTradeAmount: maxTradeAmount
            });
    }

    function marketMakerForOracle(
        address pricefeed,
        uint256 maxCumulativeDeltaDiffs
    ) external pure returns (bytes memory) {
        return abi.encode(pricefeed, maxCumulativeDeltaDiffs);
    }

    function marketMakerForFee(
        uint256 maxFRatePerDay,
        uint256 fRateFactor,
        uint256 mintFRate,
        uint256 minFundingInterval,
        uint256 fundingFeeLossOffLimit
    ) external pure returns (bytes memory) {
        return
            abi.encode(
                maxFRatePerDay,
                fRateFactor,
                mintFRate,
                minFundingInterval,
                fundingFeeLossOffLimit
            );
    }
}
