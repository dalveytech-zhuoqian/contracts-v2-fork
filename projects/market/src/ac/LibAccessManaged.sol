// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

library LibAccessManaged {
    struct AccessManagedStorage {
        address _authority;
        bool _consumingSchedule;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessManaged")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AccessManagedStorageLocation =
        0xf3177357ab46d8af007ab3fdb9af81da189e1068fefdc0073dca88a2cab40a00;

    function Storage() internal pure returns (AccessManagedStorage storage fs) {
        bytes32 position = AccessManagedStorageLocation;
        assembly {
            fs.slot := position
        }
    }
}
