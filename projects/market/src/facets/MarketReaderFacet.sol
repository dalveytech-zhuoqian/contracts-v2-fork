// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../lib/utils/EnumerableValues.sol";
import {Position} from "../lib/types/PositionStruct.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {PositionHandler} from "../lib/position/PositionHandler.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";

contract MarketReaderFacet {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    //================================================================
    //   view functions
    //================================================================
    function isLiquidate(uint16 market, address account, bool isLong) external view {
        // LibMarketValid.validateLiquidation(market, pnl, fees, liquidateFee, collateral, size, raise);
    }

    function markeConfig(uint16 market) external view returns (MarketHandler.Props memory _config) {
        _config = MarketHandler.Storage().config[market];
    }

    function getGlobalPnl(address vault) public view returns (int256) {
        EnumerableSet.UintSet storage marketIds = MarketHandler.Storage().marketIds[vault];
        uint256[] memory _markets = marketIds.values();
        int256 pnl = 0;
        for (uint256 i = 0; i < _markets.length; i++) {
            uint16 market = uint16(_markets[i]);
            pnl = pnl
                + PositionHandler.getMarketPNL(
                    market, OracleHandler.getPrice(market, true), OracleHandler.getPrice(market, false)
                );
        }
        return pnl;
    }

    function availableLiquidity(address market, address account, bool isLong) external view returns (uint256) {
        // todo for front end
    }

    function getMarket(uint16 market) external view returns (bytes memory result) {}

    function getMarkets() external view returns (bytes memory result) {}

    function getGlobalOpenInterest(uint16 market) public view returns (uint256 _globalSize) {
        // TODO
        // return MarketHandler.getGlobalOpenInterest(market);
    }
    // =================================================================================
    // read only
    // =================================================================================
}
