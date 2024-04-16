// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {MarketCache} from "./Types.sol";

library MarketDataTypes {
    function decodeCache(
        bytes memory data
    ) internal pure returns (MarketCache memory inputs) {
        // (
        //     inputs.pay,
        //     inputs.slippage,
        //     inputs.market,
        //     inputs.isLong,
        //     inputs.isOpen,
        //     inputs.isCreate,
        //     inputs.sizeDelta,
        //     inputs.price,
        //     inputs.collateralDelta,
        //     inputs.tp,
        //     inputs.sl,
        //     inputs.account,
        //     inputs.refCode,
        //     inputs.keepLev,
        //     inputs.orderId,
        //     inputs.isExec,
        //     inputs.triggerAbove,
        //     inputs.keepLevSL,
        //     inputs.keepLevTP
        // ) = abi.decode(
        //     data,
        //     (
        //         uint256,
        //         uint256,
        //         uint16,
        //         bool,
        //         bool,
        //         bool,
        //         uint256,
        //         uint256,
        //         uint256,
        //         uint256,
        //         uint256,
        //         uint64,
        //         address,
        //         bytes32,
        //         bool,
        //         uint256,
        //         bool,
        //         bool,
        //         bool,
        //         bool
        //     )
        // );
    }
}
