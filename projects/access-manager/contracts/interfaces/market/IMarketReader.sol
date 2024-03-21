// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import {IMarketFactory} from "./IMarketFactory.sol";
import {Position} from "../position/PositionStruct.sol";

interface IMarketReader {
    struct ValidOuts {
        uint256 minSlippage;
        uint256 maxSlippage;
        uint256 slippageDigits;
        uint256 minLev;
        uint256 maxLev;
        uint256 minCollateral;
        uint256 maxTradeAmount;
        bool allowOpen;
        bool allowClose;
    }

    struct MarketOuts {
        uint256 tokenDigits;
        uint256 closeFeeRate;
        uint256 openFeeRate;
        uint256 liquidationFeeUsd;
        uint256 spread;
        address indexToken;
        address collateralToken;
        address orderBookLong;
        address orderBookShort;
        address positionBook;
    }

    struct FeeOuts {
        uint256 closeFeeRate;
        uint256 openFeeRate;
        uint256 execFee;
        uint256 liquidateFee;
        uint256 digits;
    }
    struct PositionOuts {
        uint256 size;
        uint256 collateral;
        uint256 averagePrice;
        int256 entryFundingRate;
        uint256 realisedPnl;
        bool hasProfit;
        uint256 lastTime;
        bool isLong;
        uint256[] orderIDs;
    }

    function getMarkets()
        external
        view
        returns (IMarketFactory.Outs[] memory _outs);

    function isLiquidate(
        address market,
        address _account,
        bool _isLong
    ) external view returns (uint256 _state);

    function getFundingRate(
        address _market,
        bool _isLong
    ) external view returns (int256, int256);

    function availableLiquidity(
        address market,
        address account,
        bool isLong
    ) external view returns (uint256);

    function getMarket(
        address market
    )
        external
        view
        returns (
            ValidOuts memory validOuts,
            MarketOuts memory mktOuts,
            FeeOuts memory feeOuts
        );

    function getPositions(
        address account,
        address market
    ) external view returns (Position.Props[] memory _positions);

    function getFundingFee(
        address account,
        address market,
        bool isLong
    ) external view returns (int256);
}
