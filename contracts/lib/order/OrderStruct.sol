// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import {OrderKey} from "./OrderKey.sol";

library Order {
    using Order for Props;

    uint8 public constant STRUCT_VERSION = 0x01;

    struct Props {
        //====0
        bytes32 refCode;
        //====1
        uint128 collateral;
        uint128 size;
        //====2
        uint128 price;
        uint128 tp;
        //====3
        uint8 triggerAbove;
        bool fromMarket;
        bool isKeepLev;
        uint64 orderID;
        uint64 pairId;
        uint64 fromId;
        uint32 updatedAtBlock;
        uint8 extra0;
        //====4
        address account; //224
        uint96 extra1;
        //====5
        uint128 sl;
        bool isIncrease;
        bool isLong;
        uint16 market;
        uint96 extra2; //todo
    }

    function getPairKey(Props memory order) internal pure returns (bytes32) {
        return OrderKey.getKey(order.account, order.pairId);
    }

    function getKey(Props memory order) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(order.account, order.orderID));
    }

    function updateTime(Props memory _order) internal view {
        _order.updatedAtBlock = uint32(block.timestamp);
    }

    function validOrderAccountAndID(Props memory order) internal pure {
        require(order.account != address(0), "invalid order key");
        require(order.orderID != 0, "invalid order key");
    }

    function validTPSL(Props memory _order, bool _isLong) internal pure {
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
