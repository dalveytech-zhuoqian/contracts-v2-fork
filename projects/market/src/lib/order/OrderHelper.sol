// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

// import "../types/Types.sol";
import {OrderProps} from "../types/Types.sol";

library OrderHelper {
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
    function getKey(address account, uint64 orderID) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, orderID));
    }

    function storageKey(uint16 market, bool isLong, bool isIncrease) internal pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, isIncrease, market));
    }

    function getPairKey(OrderProps memory order) internal pure returns (bytes32) {
        return getKey(order.account, order.pairId);
    }

    function isMarkPriceValid(OrderProps memory _order, uint256 _oraclePrice) internal pure returns (bool) {
        if (_order.triggerAbove) return _oraclePrice >= uint256(_order.price);
        else return _oraclePrice <= uint256(_order.price);
    }
}
