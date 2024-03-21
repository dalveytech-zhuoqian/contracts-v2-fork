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

    function execAddOrderKey(Order.Props memory exeOrder, MarketDataTypes.Cache memory _params) external restricted {
        // TODO
    }

    function liquidate(uint16 market, address accounts, bool _isLong) external restricted {}

    function execSubOrderKey(Order.Props memory order, MarketDataTypes.Cache memory _params) external restricted {
        // decreasePositionFromOrder()
    }

    //========================================================================
    // private functions
    //========================================================================

    function decreasePositionFromOrder(Order.Props memory order, MarketDataTypes.Cache memory _params) private {}
}
