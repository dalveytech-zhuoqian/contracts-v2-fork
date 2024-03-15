// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketDataTypes} from "./types/MarketDataTypes.sol";
import {Position} from "./types/PositionStruct.sol";
import {Order} from "./types/OrderStruct.sol";

library MarketCbStruct {
    struct UpdatePositionEvent {
        MarketDataTypes.Cache inputs;
        Position.Props position;
        int256[] fees;
        address collateralToken;
        address indexToken;
        int256 collateralDeltaAfter;
    }

    struct DeleteOrderEvent {
        Order.Props order;
        MarketDataTypes.Cache inputs;
        uint8 reason;
        string reasonStr;
        int256 dPNL;
    }
}
