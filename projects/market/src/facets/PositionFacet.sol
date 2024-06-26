// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "../interfaces/IPositionFacet.sol";
import "../lib/utils/EnumerableValues.sol";
import {PositionProps} from "../lib/types/Types.sol";
import {IPrice} from "../interfaces/IPrice.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
//==========================================================================================
// hanlders
import {PositionHandler} from "../lib/position/PositionHandler.sol";
import {PositionStorage, PositionCache} from "../lib/position/PositionStorage.sol";

contract PositionFacet is IPositionFacet, IAccessManaged {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableValues for EnumerableSet.AddressSet;
    using EnumerableValues for EnumerableSet.UintSet;

    //==========================================================================================
    //       self functions
    //==========================================================================================
    function SELF_increasePosition(
        IncreasePositionInputs calldata _data
    ) external override onlySelf returns (PositionProps memory result) {
        PositionCache memory cache;
        cache.market = _data.market;
        cache.account = _data.account;
        cache.collateralDelta = _data.collateralDelta;
        cache.sizeDelta = _data.sizeDelta;
        cache.markPrice = _data.markPrice;
        cache.fundingRate = _data.fundingRate;
        cache.isLong = _data.isLong;
        return PositionHandler.increasePosition(cache);
    }

    function SELF_decreasePosition(
        DecreasePositionInputs calldata inputs
    ) external onlySelf returns (PositionProps memory result) {
        PositionCache memory cache;
        cache.market = inputs.market;
        cache.account = inputs.account;
        cache.collateralDelta = inputs.collateralDelta;
        cache.sizeDelta = inputs.sizeDelta;
        cache.fundingRate = inputs.fundingRate;
        cache.isLong = inputs.isLong;
        return PositionHandler.decreasePosition(cache);
    }

    function SELF_liquidatePosition(
        uint16 market,
        address account,
        uint256 oraclePrice,
        bool isLong
    ) external override onlySelf returns (PositionProps memory result) {
        PositionCache memory cache;
        cache.market = market;
        cache.account = account;
        cache.markPrice = oraclePrice;
        cache.isLong = isLong;
        return PositionHandler.liquidatePosition(cache);
    }

    //==========================================================================================
    //       view functions
    //==========================================================================================
    function isLiquidate(
        address _account,
        uint16 _market,
        bool _isLong,
        uint256 _price
    ) external view override returns (LiquidationState _state) {}

    function getAccountSize(
        uint16 market,
        address account
    ) external view returns (uint256, uint256) {
        return
            PositionStorage.getAccountSizesForBothDirections(market, account);
    }

    function getPosition(
        uint16 market,
        address account,
        uint256 markPrice,
        bool isLong
    ) public view override returns (PositionProps memory) {
        return PositionStorage.getPosition(market, account, markPrice, isLong);
    }

    function getMarketSizes(
        uint16 market
    ) external view returns (uint256, uint256) {
        return PositionStorage.getMarketSizesForBothDirections(market);
    }

    function getPositions(
        uint16 market,
        address account
    )
        external
        view
        returns (PositionProps memory posLong, PositionProps memory posShort)
    {
        return PositionStorage.getPositionsForBothDirections(market, account);
    }

    function getGlobalPosition(
        uint16 market,
        bool isLong
    ) external view returns (PositionProps memory) {
        return PositionStorage.getGlobalPosition(market, isLong);
    }

    function containsPositionOfUser(
        uint16 market,
        address account
    ) external view returns (bool) {
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        return
            ps
            .positions[PositionStorage.storageKey(market, true)][account].size >
            0 ||
            ps
            .positions[PositionStorage.storageKey(market, false)][account]
                .size >
            0;
    }

    function getPositionKeys(
        uint16 market,
        uint256 start,
        uint256 end,
        bool isLong
    ) external view returns (address[] memory) {
        // DONE
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        bytes32 k = PositionStorage.storageKey(market, isLong);
        uint256 len = ps.positionKeys[k].length();
        if (len == 0) {
            return new address[](0);
        }
        if (end > len) end = len;
        return ps.positionKeys[k].valuesAt(start, end);
    }

    function getPositionCount(
        uint16 market,
        bool isLong
    ) external view returns (uint256) {
        PositionStorage.StorageStruct storage ps = PositionStorage.Storage();
        return
            ps
                .positionKeys[PositionStorage.storageKey(market, isLong)]
                .length();
    }

    function getPNLOfUser(
        uint16 market,
        address account,
        uint256 sizeDelta,
        uint256 markPrice,
        bool isLong
    ) external view override returns (int256) {
        return
            PositionStorage.getPNL(
                market,
                account,
                sizeDelta,
                markPrice,
                isLong
            );
    }

    function getPNLOfMarket(uint16 market) external view returns (int256 pnl) {
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
