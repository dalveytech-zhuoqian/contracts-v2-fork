// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

// interfaces
import {IFeeFacet} from "../interfaces/IFeeFacet.sol";
import {IPrice} from "../interfaces/IPrice.sol";
import {IPositionFacet, IncreasePositionInputs, DecreasePositionInputs} from "../interfaces/IPositionFacet.sol";
import {IVault} from "../interfaces/IVault.sol";
import {IOrderFacet} from "../interfaces/IOrderFacet.sol";
//================================================
// handlers
import {PositionStorage} from "../lib/position/PositionStorage.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";

abstract contract PositionFacetBase {
    function _feeFacet() internal view returns (IFeeFacet) {
        return IFeeFacet(address(this));
    }

    function _positionFacet() internal view returns (IPositionFacet) {
        return IPositionFacet(address(this));
    }

    function _orderFacet() internal view returns (IOrderFacet) {
        return IOrderFacet(address(this));
    }

    function SELF_updateCumulativeFundingRate(uint16 market) internal {
        (uint256 _longSize, uint256 _shortSize) = PositionStorage
            .getMarketSizesForBothDirections(market);
        _feeFacet().SELF_updateCumulativeFundingRate(
            market,
            _longSize,
            _shortSize
        ); //1
    }

    function _getClosePrice(
        uint16 market,
        bool _isLong
    ) internal view returns (uint256 p) {
        return _priceFacet().getPrice(market, !_isLong);
    }

    function _getOpenPrice(
        uint16 market,
        bool _isLong
    ) internal view returns (uint256 p) {
        return _priceFacet().getPrice(market, _isLong);
    }

    function _priceFacet() private view returns (IPrice) {
        return IPrice(address(this));
    }

    /**
     * @dev Calculates the delta collateral for decreasing a position.
     * @return deltaCollateral The calculated delta collateral.
     */
    function getDecreaseDeltaCollateral(
        bool isKeepLev,
        uint256 size,
        uint256 dSize,
        uint256 collateral
    ) internal pure returns (uint256 deltaCollateral) {
        if (isKeepLev) {
            deltaCollateral = (collateral * dSize) / size;
        } else {
            deltaCollateral = 0;
        }
    }
}
