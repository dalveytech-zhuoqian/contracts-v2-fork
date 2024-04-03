// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

library GDataTypes {
    struct ValidParams {
        uint16 market;
        uint256 sizeDelta;
        bool isLong;
        uint256 globalLongSizes;
        uint256 globalShortSizes;
        uint256 userLongSizes;
        uint256 userShortSizes;
        uint256 marketLongSizes;
        uint256 marketShortSizes;
        uint256 aum;
    }
}
