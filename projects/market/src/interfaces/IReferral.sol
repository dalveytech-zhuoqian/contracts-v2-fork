// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MarketCache, PositionProps, OrderProps} from "../lib/types/Types.sol";

struct ReferralUpdatePositionEvent {
    MarketCache inputs;
    PositionProps position;
    int256[] fees;
    address collateralToken;
    address indexToken;
    int256 collateralDeltaAfter;
}

struct ReferralDeleteOrderEvent {
    OrderProps order;
    MarketCache inputs;
    uint8 reason;
    string reasonStr;
    int256 dPNL;
}

interface IReferral {
    function SELF_updatePositionCallback(
        ReferralUpdatePositionEvent calldata _event
    ) external;
}
