// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {OrderProps, MarketCache} from "../lib/types/Types.sol";

interface IOrderFacet {
    function updateOrder(MarketCache calldata _inputs) external payable;

    function cancelOrder(address account, uint16 market, bool isIncrease, uint256 orderID, bool isLong)
        external
        returns (OrderProps[] memory _orders);

    function _addOrders(MarketCache[] memory _inputs) external returns (OrderProps[] memory _orders);
}
