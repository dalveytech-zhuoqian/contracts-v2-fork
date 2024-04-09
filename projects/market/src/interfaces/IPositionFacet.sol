// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {PositionProps, LiquidationState} from "../lib/types/Types.sol";

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
    function _increasePosition(IncreasePositionInputs calldata _data) external returns (PositionProps memory);
    function _decreasePosition(DecreasePositionInputs calldata _data) external returns (PositionProps memory);
    function _liquidatePosition(uint16 market, address account, uint256 oraclePrice, bool isLong)
        external
        returns (PositionProps memory result);
    //====================================
    // view
    function getPositionKeys(uint16 market, uint256 start, uint256 end, bool isLong)
        external
        view
        returns (address[] memory);

    function isLiquidate(address _account, uint16 _market, bool _isLong, uint256 _price)
        external
        view
        returns (LiquidationState _state);

    function getPNLOfUser(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        returns (int256);
    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        view
        returns (PositionProps memory);
}
