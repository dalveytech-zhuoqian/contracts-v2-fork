// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessManaged} from "./LibAccessManaged.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";

contract AccessManagedFacet {
    event AuthorityUpdated(address authority);

    function setAuthority(address newAuthority) public {
        require(
            LibAccessManaged.Storage()._authority == address(0),
            "AccessManagedFacet: authority already set"
        );
        require(
            newAuthority != address(0),
            "AccessManagedFacet: new authority is the zero address"
        );
        LibAccessManaged.Storage()._authority = newAuthority;
        emit AuthorityUpdated(newAuthority);
    }

    function authority() public view returns (address) {
        return LibAccessManaged.Storage()._authority;
    }
}
