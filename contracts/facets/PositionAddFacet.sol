// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
import {Order} from "../lib/types/OrderStruct.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract PositionAddFacet is IAccessManaged, ReentrancyGuardUpgradeable {
    function initialize() public initializer {
        __ReentrancyGuard_init();
    }

    function increasePosition(bytes calldata _data) external {
        // TODO
        MarketDataTypes.Cache memory _inputs = MarketDataTypes.decodeCache(_data);
    }

    function execAddOrderKey(Order.Props memory exeOrder, MarketDataTypes.Cache memory _params) external restricted {
        // TODO
    }
}
