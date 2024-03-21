// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

library Order {
    using Order for Props;

    uint8 public constant STRUCT_VERSION = 0x01;

    struct Props {
        uint8 version;
        uint32 updatedAtBlock;
        //***************************************************
        //             Definition of triggerAbove
        //---------------------------------------------------
        // value 0: INVALID;
        // value 2 or 4: triggerAbove is false;
        // value 1 or 3: triggerAbove is true;
        // value 1 or 2: fromMarket is false;
        // value 3 or 4: fromMarket is true;
        uint8 triggerAbove;
        //***************************************************

        address account;
        //***************************************************
        //             Definition of extra3
        //---------------------------------------------------
        // Open-Order meanings: isFromMarket(1 for true, 0 for false)
        // Close-Order meanings: isKeepLev
        uint48 extra3;
        //***************************************************

        //***************************************************
        //             Definition of collateral
        //---------------------------------------------------
        // Open-Order meanings: pay
        // Close-Order meanings: collateralDelta
        uint128 collateral;
        //***************************************************

        uint128 size;
        uint128 price;
        //***************************************************
        //             Definition of extra1
        //---------------------------------------------------
        // Open-Order meanings: take-profit
        // Close-Order meanings: NULL
        uint128 extra1;
        //***************************************************

        uint64 orderID;
        //***************************************************
        //             Definition of extra2
        //---------------------------------------------------
        // Open-Order meanings: keep leverage on tp/sl
        // Close-Order meanings: order to order id(as known as: pairKey)
        uint64 extra2;
        //***************************************************

        //***************************************************
        //             Definition of extra0
        //---------------------------------------------------
        // Open-Order meanings: stop-loss
        // Close-Order meanings: from order id
        uint128 extra0;
        //***************************************************

        bytes32 refCode; //160
        //96 todo uint96 extra4;
    }
}
