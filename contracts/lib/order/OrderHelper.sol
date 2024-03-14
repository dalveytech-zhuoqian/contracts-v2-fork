// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import {Order} from "../types/OrderStruct.sol";

library OrderHelper {
    function getKey(address account, uint64 orderID) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, orderID));
    }

    function storageKey(uint16 market, bool isLong, bool isIncrease) internal pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, isIncrease, market));
    }

    function getPairKey(Order.Props memory order) internal pure returns (bytes32) {
        return OrderHelper.getKey(order.account, order.pairId);
    }
}
