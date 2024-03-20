// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Context} from "@openzeppelin/utils/Context.sol";
import {IAccessManaged} from "@openzeppelin/access/manager/IAccessManaged.sol";
import {LibAccessManaged} from "./LibAccessManaged.sol";
import {LibDiamond} from "../diamond/contracts/libraries/LibDiamond.sol";

contract AccessManagedFacet is Context, IAccessManaged {
    /// @inheritdoc IAccessManaged
    function authority() public view virtual returns (address) {
        return LibDiamond.contractOwner();
    }

    /// @inheritdoc IAccessManaged
    function setAuthority(address newAuthority) public virtual {
        address caller = _msgSender();
        if (caller != authority()) {
            revert AccessManagedUnauthorized(caller);
        }
        if (newAuthority.code.length == 0) {
            revert AccessManagedInvalidAuthority(newAuthority);
        }
        _setAuthority(newAuthority);
    }

    /// @inheritdoc IAccessManaged
    function isConsumingScheduledOp() public view returns (bytes4) {
        return LibAccessManaged.Storage().consumingSchedule ? this.isConsumingScheduledOp.selector : bytes4(0);
    }

    /**
     * @dev Transfers control to a new authority. Internal function with no access restriction. Allows bypassing the
     * permissions set by the current authority.
     */
    function _setAuthority(address newAuthority) internal virtual {
        LibDiamond.setContractOwner(newAuthority);
        emit AuthorityUpdated(newAuthority);
    }
}
