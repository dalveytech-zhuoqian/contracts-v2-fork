// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../lib/utils/EnumerableValues.sol";
import {Position} from "../lib/types/PositionStruct.sol";
import {IPrice} from "../interfaces/IPrice.sol";

import {IPositionFacet} from "../interfaces/IPositionFacet.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
//==========================================================================================
// hanlders
import {PositionHandler} from "../lib/position/PositionHandler.sol";
import {PositionStorage} from "../lib/position/PositionStorage.sol";

contract PositionFacet is IPositionFacet, IAccessManaged {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    //==========================================================================================
    //       self functions
    //==========================================================================================
    function increasePosition(bytes memory _data) external override onlySelf returns (Position.Props memory result) {
        result = PositionHandler.increasePosition(_data);
    }

    function decreasePosition(bytes memory _data) external onlySelf returns (Position.Props memory result) {
        result = PositionHandler.decreasePosition(_data);
    }
    //==========================================================================================
    //       view functions
    //==========================================================================================

    function getAccountSize(uint16 market, address account) external view returns (uint256, uint256) {
        return PositionStorage.getAccountSize(market, account);
    }

    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        public
        view
        override
        returns (Position.Props memory)
    {
        return PositionStorage.getPosition(market, account, markPrice, isLong);
    }

    function getMarketSizes(uint16 market) external view returns (uint256, uint256) {
        return PositionStorage.getMarketSizes(market);
    }

    function getPositions(uint16 market, address account)
        external
        view
        returns (Position.Props memory posLong, Position.Props memory posShort)
    {
        return PositionStorage.getPositions(market, account);
    }

    function getGlobalPosition(uint16 market, bool isLong) external view returns (Position.Props memory) {
        return PositionStorage.getGlobalPosition(market, isLong);
    }

    function contains(uint16 market, address account) external view returns (bool) {
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        return ps.positions[PositionStorage.storageKey(market, true)][account].size > 0
            || ps.positions[PositionStorage.storageKey(market, false)][account].size > 0;
    }

    function getPositionKeys(uint16 market, uint256 start, uint256 end, bool isLong)
        external
        view
        returns (address[] memory)
    {
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        return ps.positionKeys[PositionStorage.storageKey(market, isLong)].valuesAt(start, end);
    }

    function getPositionCount(uint16 market, bool isLong) external view returns (uint256) {
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        return ps.positionKeys[PositionStorage.storageKey(market, isLong)].length();
    }

    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        override
        returns (int256)
    {
        return PositionStorage.getPNL(market, account, sizeDelta, markPrice, isLong);
    }

    function getPNL(uint16 market) external view returns (int256 pnl) {
        // TODO
        // uint256 longPrice = IPrice(this).getPrice(market, false);
        // uint256 shortPrice = IPrice(this).getPrice(market, true);
        // pnl = TransferHelper.parseVaultAssetSigned(
        //     PositionHandler.getMarketPNL(market, longPrice, shortPrice), collateralTokenDigits
        // );
    }

    //==========================================================================================
    //       private functions
    //==========================================================================================
}