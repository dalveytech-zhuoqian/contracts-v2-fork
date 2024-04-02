// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

// interfaces
import {IFeeFacet} from "../interfaces/IFeeFacet.sol";
import {IPrice} from "../interfaces/IPrice.sol";
import {IMarketInternal} from "../interfaces/IMarketInternal.sol";
import {IPositionFacet} from "../interfaces/IPositionFacet.sol";
import {IVault} from "../interfaces/IVault.sol";
//================================================
// handlers
import {PositionStorage} from "../lib/position/PositionStorage.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";

abstract contract PositionFacetBase {
    function _feeFacet() internal view returns (IFeeFacet) {
        return IFeeFacet(address(this));
    }

    function _marketFacet() internal view returns (IMarketInternal) {
        return IMarketInternal(address(this));
    }

    function _priceFacet() internal view returns (IPrice) {
        return IPrice(address(this));
    }

    function _positionFacet() internal view returns (IPositionFacet) {
        return IPositionFacet(address(this));
    }

    function vault(uint16 market) internal view returns (IVault) {
        return IVault(MarketHandler.vault(market));
    }

    function _updateCumulativeFundingRate(uint16 market) internal {
        (uint256 _longSize, uint256 _shortSize) = PositionStorage.getMarketSizes(market);
        _feeFacet().updateCumulativeFundingRate(market, _longSize, _shortSize); //1
    }
}
