// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Order} from "./OrderStruct.sol";

library OrderHandler { /* is IOrderBook, Ac */
    bytes32 constant OB_STORAGE_POSITION = keccak256("blex.orderbook.storage");

    struct OrderStorage {
        mapping(bytes32 => mapping(bytes32 => Order.Props)) orders; // keyorder
        mapping(bytes32 => mapping(address => uint256)) ordersIndex; // orderID
        mapping(bytes32 => mapping(address => uint256)) orderNum; // order
        mapping(bytes32 => mapping(address => EnumerableSet.Bytes32Set)) ordersByAccount; // position => order
        mapping(bytes32 => EnumerableSet.Bytes32Set) orderKeys; // orderkey
    }

    function storageKey(uint16 market, bool isLong, bool isIncrease) public pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, isIncrease, market));
    }

    function Storage() internal pure returns (OrderStorage storage fs) {
        bytes32 position = OB_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function cancelOrder(address account, uint16 market, bool isIncrease, uint256 orderID, bool isLong) public {
        bytes32 sk = storageKey(market, isLong, isIncrease);
        // TODO delete order
    }

    function sysCancelOrder(
        bytes32[] memory _orderKey,
        bool[] memory _isLong,
        bool[] memory _isIncrease,
        string[] memory reasons
    ) internal {}

    function add(MarketDataTypes.UpdateOrderInputs[] memory _vars) internal returns (Order.Props[] memory _orders) {}

    function update(MarketDataTypes.UpdateOrderInputs memory _vars /*nonReentrant*/ )
        internal
        returns (Order.Props memory _order)
    {}

    function removeByAccount(bool isOpen, bool isLong, address account)
        internal
        returns (Order.Props[] memory _orders)
    {}

    function remove(address account, uint256 orderID, bool isOpen, bool isLong)
        internal
        returns (Order.Props[] memory _orders)
    {}

    function delByAccount(address account) internal returns (Order.Props[] memory _orders) {}

    function getOrderByAccount(address account) internal view returns (Order.Props[] memory _orders) {}

    function getByIndex(uint256 index) internal view returns (Order.Props memory) {}

    function containsKey(bytes32 key) internal view returns (bool) {}

    function getCount() internal view returns (uint256) {}

    function getKey(uint256 _index) internal view returns (bytes32) {}

    function getKeys(uint256 start, uint256 end) internal view returns (bytes32[] memory) {}
}
