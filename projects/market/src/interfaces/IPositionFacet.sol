// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PositionProps} from "../lib/types/Types.sol";

struct IncreasePositionInputs {
    uint16 market;
    address account;
    int256 collateralDelta;
    uint256 sizeDelta;
    uint256 markPrice;
    int256 fundingRate;
    bool isLong;
}

struct DecreasePositionInputs {
    uint16 market;
    address account;
    int256 collateralDelta;
    uint256 sizeDelta;
    int256 fundingRate;
    bool isLong;
}

interface IPositionFacet {
    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        returns (int256);

    function increasePosition(IncreasePositionInputs calldata _data) external returns (PositionProps memory);
    function decreasePosition(DecreasePositionInputs calldata _data) external returns (PositionProps memory);
    function liquidatePosition(uint16 market, address account, uint256 oraclePrice, bool isLong)
        external
        returns (PositionProps memory result);

    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        view
        returns (PositionProps memory);
}
