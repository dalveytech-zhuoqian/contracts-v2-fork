// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
pragma abicoder v2;

import {OrderProps} from "./Types.sol";

library Order {
    uint8 internal constant STRUCT_VERSION = 0x01;

    function getKey(OrderProps memory order) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(order.account, order.orderID));
    }

    function updateTime(OrderProps memory _order) internal view {
        _order.updatedAtBlock = uint32(block.timestamp);
    }

    // 精度
    // 创建结构体
    // valid
    // 转换结构体
}
