// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../lib/utils/EnumerableValues.sol";
import {Position} from "../lib/types/PositionStruct.sol";
import {IPrice} from "../interfaces/IPrice.sol";

import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {PositionHandler} from "../lib/position/PositionHandler.sol";
import {OracleHandler} from "../lib/oracle/OracleHandler.sol";
import {FeeHandler} from "../lib/fee/FeeHandler.sol";
import {IPositionFacet} from "../interfaces/IPositionFacet.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";

contract PositionFacet is IPositionFacet, IAccessManaged {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    function getAccountSize(uint16 market, address account) external view returns (uint256, uint256) {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return (
            ps.positions[PositionHandler.storageKey(market, true)][account].size,
            ps.positions[PositionHandler.storageKey(market, false)][account].size
        );
    }

    function increasePosition(bytes memory _data) external override onlySelf returns (Position.Props memory result) {
        result = PositionHandler.increasePosition(_data);
    }

    function decreasePosition(bytes memory _data) external onlySelf returns (Position.Props memory result) {
        result = PositionHandler.decreasePosition(_data);
    }

    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        public
        view
        override
        returns (Position.Props memory)
    {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        // TODO
        return ps.positions[PositionHandler.storageKey(market, isLong)][account];
    }

    function getMarketSizes(uint16 market) external view returns (uint256, uint256) {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return (
            ps.globalPositions[PositionHandler.storageKey(market, true)].size,
            ps.globalPositions[PositionHandler.storageKey(market, false)].size
        );
    }

    function getPositions(uint16 market, address account)
        external
        view
        returns (Position.Props memory posLong, Position.Props memory posShort)
    {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        posLong = ps.positions[PositionHandler.storageKey(market, true)][account];
        posShort = ps.positions[PositionHandler.storageKey(market, false)][account];
    }

    function getGlobalPosition(uint16 market, bool isLong) external view returns (Position.Props memory) {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return ps.globalPositions[PositionHandler.storageKey(market, isLong)];
    }

    function contains(uint16 market, address account) external view returns (bool) {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return ps.positions[PositionHandler.storageKey(market, true)][account].size > 0
            || ps.positions[PositionHandler.storageKey(market, false)][account].size > 0;
    }

    function getPositionKeys(uint16 market, uint256 start, uint256 end, bool isLong)
        external
        view
        returns (address[] memory)
    {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return ps.positionKeys[PositionHandler.storageKey(market, isLong)].valuesAt(start, end);
    }

    function getPositionCount(uint16 market, bool isLong) external view returns (uint256) {
        PositionHandler.PositionStorage storage ps = PositionHandler.Storage();
        return ps.positionKeys[PositionHandler.storageKey(market, isLong)].length();
    }

    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        override
        returns (int256)
    {
        //todo
        // Position.Props memory _position = getPosition(market, account, markPrice, isLong);
        // return PositionHandler.getPNL(_position, sizeDelta, markPrice);
    }

    function getPNL(uint16 market) external view returns (int256 pnl) {
        // TODO
        // uint256 longPrice = IPrice(this).getPrice(market, false);
        // uint256 shortPrice = IPrice(this).getPrice(market, true);
        // pnl = TransferHelper.parseVaultAssetSigned(
        //     PositionHandler.getMarketPNL(market, longPrice, shortPrice), collateralTokenDigits
        // );
    }
}
