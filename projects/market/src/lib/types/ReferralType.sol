// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "./Types.sol";

library ReferralType {
    struct UpdatePositionEvent {
        MarketCache inputs;
        PositionProps position;
        int256[] fees;
        address collateralToken;
        address indexToken;
        int256 collateralDeltaAfter;
    }

    struct DeleteOrderEvent {
        OrderProps order;
        MarketCache inputs;
        uint8 reason;
        string reasonStr;
        int256 dPNL;
    }
}
