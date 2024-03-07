// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library MarketDataTypes {
    struct UpdateOrderInputs {
        uint256 oraclePrice;
        uint256 pay;
        uint256 slippage;
        uint16 market;
        bool isLong;
        bool isOpen;
        bool isCreate;
        bool isFromMarket;
    }

    struct UpdatePositionInputs {
        uint256 oraclePrice;
        uint256 sizeDelta;
        uint256 price;
        uint256 slippage;
        uint256 collateralDelta;
        uint256 tp;
        uint256 sl;
        uint16 market;
        bool isLong;
        bool isOpen;
        address account;
        bool isExec;
        uint8 liqState;
        uint64 fromOrder;
        bytes32 refCode;
        uint8 execNum;
        bool keepLev;
    }
}
