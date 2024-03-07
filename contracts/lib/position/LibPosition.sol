// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

import {Position} from "./Position.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibPosition {
    bytes32 constant POS_STORAGE_POSITION = keccak256("blex.position.storage");

    struct PositionStorage {
        // save user position, address -> position
        mapping(bytes32 => mapping(address => Position.Props)) positions;
        // set of position address
        mapping(bytes32 => EnumerableSet.AddressSet) positionKeys;
        // global position
        mapping(bytes32 => Position.Props) globalPositions;
    }

    event UpdatePosition(address indexed account, uint256 size, uint256 collateral);
    event RemovePosition(address indexed account, uint256 size, uint256 collateral);

    function Storage() internal pure returns (PositionStorage storage fs) {
        bytes32 position = POS_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function storageKey(uint16 market, bool isLong) public pure returns (bytes32 orderKey) {
        return bytes32(abi.encodePacked(isLong, market));
    }

    function increasePosition(
        uint16 market,
        address account,
        int256 collateralDelta,
        uint256 sizeDelta,
        uint256 markPrice,
        int256 fundingRate,
        bool isLong
    ) external returns (Position.Props memory result) {}

    function decreasePosition(
        uint16 market,
        address account,
        uint256 collateralDelta,
        uint256 sizeDelta,
        int256 fundingRate,
        bool isLong
    ) external returns (Position.Props memory result) {}

    function decreaseCollateralFromCancelInvalidOrder(
        uint16 market,
        address account,
        uint256 collateralDelta,
        bool isLong
    ) external returns (uint256) {}

    function liquidatePosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        returns (Position.Props memory result)
    {}

    // =====================================================
    //           view only
    // =====================================================
}
