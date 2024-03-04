// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

contract OrderBook /* is IOrderBook, Ac */ {
    
    function getExecutableOrdersByPrice(
        uint256 start,
        uint256 end,
        bool isOpen,
        uint256 _oraclePrice
    ) external view override returns (Order.Props[] memory _orders) {
    }
 
    function add(
        MarketDataTypes.UpdateOrderInputs[] memory _vars
    ) external override onlyController returns (Order.Props[] memory _orders) {
    }

    function update(
        MarketDataTypes.UpdateOrderInputs memory _vars /*nonReentrant*/
    ) external override onlyController returns (Order.Props memory _order) {
    }

    function removeByAccount(
        bool isOpen,
        bool isLong,
        address account
    ) external override onlyController returns (Order.Props[] memory _orders) {
    }

    function remove(
        address account,
        uint256 orderID,
        bool isOpen,
        bool isLong
    ) external override onlyController returns (Order.Props[] memory _orders) {
    }

    function remove(
        bytes32 key,
        bool isOpen,
        bool isLong
    ) public override onlyController returns (Order.Props[] memory _orders) {
    }

    function add(Order.Props memory order) external onlyController {
    }
    
    function set(Order.Props memory order) external onlyController {
    }

    function remove(
        bytes32 key
    ) external onlyController returns (Order.Props memory order) {
    }
    
    function delByAccount(
        address account
    ) external onlyController returns (Order.Props[] memory _orders) {
    }

    function getOrderByAccount(
        address account
    ) external view returns (Order.Props[] memory _orders) {
    }

    function getByIndex(
        uint256 index
    ) external view returns (Order.Props memory) {
    }

    function containsKey(bytes32 key) external view returns (bool) {
    }

    function getCount() external view returns (uint256) {
    }

    function getKey(uint256 _index) external view returns (bytes32) {
    }

    function getKeys(
        uint256 start,
        uint256 end
    ) external view returns (bytes32[] memory) {
    }

    function generateID(
        address _acc
    ) external onlyController returns (uint256 retVal) {
    }

}
