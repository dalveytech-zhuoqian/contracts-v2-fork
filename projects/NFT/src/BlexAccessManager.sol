// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessManagerUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";

contract BlexAccessManager is AccessManagerUpgradeable {
    function initialize(address admin) public initializer {
        __AccessManager_init(admin);
    }
}
