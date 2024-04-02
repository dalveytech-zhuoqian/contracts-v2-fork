// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessManaged} from "./LibAccessManaged.sol";
import {AuthorityUtils} from "@openzeppelin/contracts/access/manager/AuthorityUtils.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/IAccessManager.sol";

abstract contract IAccessManaged {
    error AccessManagedUnauthorized(address caller);
    error AccessManagedRequiredDelay(address caller, uint32 delay);
    error AccessManagedInvalidAuthority(address authority);

    modifier restricted() {
        //todo
        // _checkCanCall(msg.sender, msg.data);
        _;
    }

    modifier onlySelf() {
        //todo
        // require(msg.sender == address(this), "AccessManaged: only self");
        _;
    }

    modifier onlySelfOrRestricted() {
        // todo
        _;
    }

    function _authority() internal view returns (address) {
        return LibAccessManaged.Storage()._authority;
    }

    function _checkCanCall(address caller, bytes calldata data) internal {
        LibAccessManaged.AccessManagedStorage storage $ = LibAccessManaged.Storage();
        (bool immediate, uint32 delay) =
            AuthorityUtils.canCallWithDelay(_authority(), caller, address(this), bytes4(data[0:4]));
        if (!immediate) {
            if (delay > 0) {
                $._consumingSchedule = true;
                IAccessManager(_authority()).consumeScheduledOp(caller, data);
                $._consumingSchedule = false;
            } else {
                revert AccessManagedUnauthorized(caller);
            }
        }
    }
}
