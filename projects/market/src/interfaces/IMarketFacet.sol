// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OrderProps} from "./../lib/types/Types.sol";

struct OrderFinderCache {
    uint16 market;
    bool isLong;
    bool isIncrease;
    uint256 start;
    uint256 end;
    bool isOpen;
    uint256 oraclePrice;
    bytes32 storageKey;
}

interface IMarketFacet {
    //================================================================
    // view functions
    //================================================================
    function getExecutableOrdersByPrice(
        OrderFinderCache memory cache
    ) external view returns (OrderProps[] memory _orders);
}
