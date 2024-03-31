// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
import {Order} from "../lib/types/OrderStruct.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract PositionAddFacet is IAccessManaged {
    function execAddOrderKey(Order.Props memory exeOrder, MarketDataTypes.Cache memory _params) external restricted {
        // TODO
    }
}
