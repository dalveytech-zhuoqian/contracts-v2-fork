// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "../types/Types.sol";

library OrderHelper {
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
