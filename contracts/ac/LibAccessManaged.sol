// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "../diamond-2/contracts/libraries/LibDiamond.sol";
import {IAccessManager} from "openzeppelin_5_contracts/access/manager/IAccessManager.sol";
import {AuthorityUtils} from "openzeppelin_5_contracts/access/manager/AuthorityUtils.sol";
import {IAccessManaged} from "openzeppelin_5_contracts/access/manager/IAccessManaged.sol";

library LibAccessManaged {
    bytes32 private constant STORAGE_POSITION = keccak256("blex.access.managed.storage");
    uint256 public constant PRECISION = 10 ** 8;

    struct AccessStorage {
        bool consumingSchedule;
    }

    function Storage() internal pure returns (AccessStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
        return s;
    }

    /**
     * @dev Restricts access to a function as defined by the connected Authority for this contract and the
     * caller and selector of the function that entered the contract.
     *
     * [IMPORTANT]
     * ====
     * In general, this modifier should only be used on `external` functions. It is okay to use it on `public`
     * functions that are used as external entry points and are not called internally. Unless you know what you're
     * doing, it should never be used on `internal` functions. Failure to follow these rules can have critical security
     * implications! This is because the permissions are determined by the function that entered the contract, i.e. the
     * function at the bottom of the call stack, and not the function where the modifier is visible in the source code.
     * ====
     *
     * [WARNING]
     * ====
     * Avoid adding this modifier to the https://docs.soliditylang.org/en/v0.8.20/contracts.html#receive-ether-function[`receive()`]
     * function or the https://docs.soliditylang.org/en/v0.8.20/contracts.html#fallback-function[`fallback()`]. These
     * functions are the only execution paths where a function selector cannot be unambiguosly determined from the calldata
     * since the selector defaults to `0x00000000` in the `receive()` function and similarly in the `fallback()` function
     * if no calldata is provided. (See {_checkCanCall}).
     *
     * The `receive()` function will always panic whereas the `fallback()` may panic depending on the calldata length.
     * ====
     */
    function restricted() internal {
        _checkCanCall(msg.sender, msg.data);
    }

    /**
     * @dev Reverts if the caller is not allowed to call the function identified by a selector. Panics if the calldata
     * is less than 4 bytes long.
     */
    function _checkCanCall(address caller, bytes calldata data) private {
        if (msg.sender == address(this)) return;
        (bool immediate, uint32 delay) = AuthorityUtils.canCallWithDelay(
            LibDiamond.contractOwner(),
            caller,
            address(this),
            bytes4(data[0 : 4])
        );
        if (!immediate) {
            if (delay > 0) {
                Storage().consumingSchedule = true;
                IAccessManager(LibDiamond.contractOwner()).consumeScheduledOp(caller, data);
                Storage().consumingSchedule = false;
            } else {
                revert IAccessManaged.AccessManagedUnauthorized(caller);
            }
        }
    }
}
