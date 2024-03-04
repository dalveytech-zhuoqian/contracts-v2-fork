// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

library LibPosition{

    struct PositionStorage {
        // position long/short status
        bool  isLong;
        // save user position, address -> position
        mapping(address => Position.Props)  positions;
        // set of position address
        EnumerableSet.AddressSet  positionKeys;
        // global position
        Position.Props  globalPositions;
        address  oldPositionStore;
    }
  
}