// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessManaged} from "./LibAccessManaged.sol";

abstract contract IAccessManaged {
    modifier restricted() {
        LibAccessManaged.restricted();
        _;
    }
}
