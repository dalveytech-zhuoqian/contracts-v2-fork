// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library MarketDataTypes {
    struct Cache {
        uint256 oraclePrice;
        uint256 pay;
        uint256 slippage;
        uint16 market;
        bool isLong;
        bool isOpen;
        bool isCreate;
        bool isFromMarket;
        uint256 sizeDelta;
        uint256 price;
        uint256 collateralDelta;
        uint256 tp;
        uint256 sl;
        address account;
        bool isExec;
        uint8 liqState;
        uint64 fromOrder;
        bytes32 refCode;
        uint8 execNum;
        bool keepLev;
    }

    function decodeUpdateOrderInputs(bytes memory data) internal pure returns (Cache memory inputs) {
        (
            inputs.pay,
            inputs.slippage,
            inputs.market,
            inputs.isLong,
            inputs.isOpen,
            inputs.isCreate,
            inputs.sizeDelta,
            inputs.price,
            inputs.collateralDelta,
            inputs.tp,
            inputs.sl,
            inputs.account,
            inputs.refCode,
            inputs.keepLev,
            inputs.isExec
        ) = abi.decode(
            data,
            (
                uint256,
                uint256,
                uint16,
                bool,
                bool,
                bool,
                uint256,
                uint256,
                uint256,
                uint256,
                uint256,
                address,
                bytes32,
                bool,
                bool
            )
        );
    }
}
