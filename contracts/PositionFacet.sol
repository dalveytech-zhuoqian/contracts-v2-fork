// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;

contract PositionBookV2 /* is AcUpgradable */ {
    event UpdatePosition(
        address indexed account,
        uint256 size,
        uint256 collateral
    );
    event RemovePosition(
        address indexed account,
        uint256 size,
        uint256 collateral
    );
    function getMarketSizes(address market) external view returns (uint256, uint256) {
    }

    function getAccountSize(
        address market,
        address account
    ) external view returns (uint256, uint256) {
    }

    function getPosition(
        address market,
        address account,
        uint256 markPrice,
        bool isLong
    ) external view returns (Position.Props memory) {
    }

    function getPositions(
        address market,
        address account
    ) external view returns (Position.Props[] memory) {
    }

    function getPositionKeys(
        address market,
        uint256 start,
        uint256 end,
        bool isLong
    ) external view returns (address[] memory) {
    }

    function getPositionCount(address market,bool isLong) external view returns (uint256) {
     
    }

    function getPNL(
        address market,
        address account,
        uint256 sizeDelta,
        uint256 markPrice,
        bool isLong
    ) external view returns (int256) {
   
    }

    function getMarketPNL(
        address market,
        uint256 longPrice,
        uint256 shortPrice
    ) external view returns (int256) {
     
    }

    function increasePosition(
        address market,
        address account,
        int256 collateralDelta,
        uint256 sizeDelta,
        uint256 markPrice,
        int256 fundingRate,
        bool isLong
    ) external restricted returns (Position.Props memory result) {
    }

    function decreasePosition(
        address market,
        address account,
        uint256 collateralDelta,
        uint256 sizeDelta,
        int256 fundingRate,
        bool isLong
    ) external restricted returns (Position.Props memory result) {
    }

    function decreaseCollateralFromCancelInvalidOrder(
        address market,
        address account,
        uint256 collateralDelta,
        bool isLong
    ) external restricted returns (uint256) {
    }

    function liquidatePosition(
        address market,
        address account,
        uint256 markPrice,
        bool isLong
    ) external restricted returns (Position.Props memory result) {
    } 

    // =====================================================
    //           position store
    // =====================================================
    function globalSize() external view returns (uint256) {
    }

    function getGlobalPosition() external view returns (Position.Props memory) {
    }

    function get(
        address account
    ) external view returns (Position.Props memory) {
    }

    function contains(address account) external view returns (bool) {
    }

    function getPositionCount() public view returns (uint256) {
    }

    function getPositionKeys(
        uint256 start,
        uint256 end
    ) external view returns (address[] memory) {
    }

 
}
