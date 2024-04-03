// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketDataTypes} from "./MarketDataTypes.sol";
import {Position} from "./PositionStruct.sol";
import {Order} from "./OrderStruct.sol";

library ReferralType {
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
