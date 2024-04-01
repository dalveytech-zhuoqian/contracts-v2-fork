// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

library GDataTypes {
    struct ValidParams {
        uint128 sizeDelta;
        uint128 globalLongSizes;
        uint128 globalShortSizes;
        uint128 userLongSizes;
        uint128 userShortSizes;
        uint128 marketLongSizes;
        uint128 marketShortSizes;
        uint128 aum;
        bool isLong;
        uint16 market;
    }
}
