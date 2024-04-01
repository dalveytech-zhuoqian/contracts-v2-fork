// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Position} from "../types/PositionStruct.sol";
import {PositionHandler} from "../position/PositionHandler.sol";

library MarketReadHelper {
    function getGlobalPnl(address vault) public view returns (int256) {
        // EnumerableSet.UintSet storage marketIds = MarketHandler.Storage().marketIds[vault];
        // uint256[] memory _markets = marketIds.values();
        // int256 pnl = 0;
        // for (uint256 i = 0; i < _markets.length; i++) {
        //     uint16 market = uint16(_markets[i]);
        //     pnl = pnl
        //         + PositionHandler.getMarketPNL(
        //             market, OracleHandler.getPrice(market, true), OracleHandler.getPrice(market, false)
        //         );
        // }
        // return pnl;
    }
}
