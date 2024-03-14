// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

library FeeType {
    enum T {
        OpenFee, // 0
        CloseFee, // 1
        FundFee, // 2
        ExecFee, // 3
        LiqFee, // 4
        BuyLpFee, // 5
        SellLpFee, // 6
        ExtraFee0,
        ExtraFee1,
        ExtraFee2,
        ExtraFee3,
        ExtraFee4,
        Counter
    }
}
