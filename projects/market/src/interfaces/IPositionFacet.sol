// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Position} from "../lib/types/PositionStruct.sol";

interface IPositionFacet {
    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        returns (int256);

    function increasePosition(bytes memory _data) external returns (Position.Props memory);
    function decreasePosition(bytes memory _data) external returns (Position.Props memory);
    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        view
        returns (Position.Props memory);
}
