// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketCache} from "../types/Types.sol";

library Event {
    event UpdateOrder(
        address indexed account,
        bool isLong,
        bool isIncrease,
        uint256 orderID,
        address market,
        uint256 size,
        uint256 collateral,
        uint256 triggerPrice,
        bool triggerAbove,
        uint256 tp,
        uint256 sl,
        uint128 fromOrder,
        bool isKeepLev,
        MarketCache params
    );

    event DeleteOrder(
        address indexed account,
        bool isLong,
        bool isIncrease,
        uint256 orderID,
        uint16 market,
        uint8 reason,
        string reasonStr,
        uint256 price,
        int256 dPNL
    );
}
