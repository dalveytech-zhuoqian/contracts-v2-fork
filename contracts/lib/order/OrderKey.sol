// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

library OrderKey {
    function getKey(address account, uint64 orderID) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, orderID));
    }
}
