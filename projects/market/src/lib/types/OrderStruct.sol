// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
pragma abicoder v2;

import {OrderProps} from "./Types.sol";

library Order {
    using Order for OrderProps;

    uint8 internal constant STRUCT_VERSION = 0x01;

    function getKey(OrderProps memory order) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(order.account, order.orderID));
    }

    function updateTime(OrderProps memory _order) internal view {
        _order.updatedAtBlock = uint32(block.timestamp);
    }

    function isMarkPriceValid(OrderProps memory _order, uint256 _oraclePrice) internal pure returns (bool) {
        // TODO
        return _order.isFromMarket || _order.price == _oraclePrice;
    }

    function validOrderAccountAndID(OrderProps memory order) internal pure {
        require(order.account != address(0), "invalid order key");
        require(order.orderID != 0, "invalid order key");
    }

    function validTPSL(OrderProps memory _order, bool _isLong) internal pure {
        if (_order.tp > 0) {
            require(_order.tp > _order.price == _isLong, "OrderBook:tp<price");
        }
        if (_order.sl > 0) {
            require(_order.price > _order.sl == _isLong, "OrderBook:sl>price");
        }
    }
    // 精度
    // 创建结构体
    // valid
    // 转换结构体
}
