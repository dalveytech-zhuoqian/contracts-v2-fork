// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

// import {OrderProps, PositionProps, MarketCache, MarketBusinessType} from "./Types.sol";
import "./Types.sol";
import {MarketHandler} from "../market/MarketHandler.sol";
import {PercentageMath} from "../utils/PercentageMath.sol";

library Validations {
    using PercentageMath for uint256;

    function validLev(uint16 market, uint256 newSize, uint256 newCollateral) internal view {
        if (newSize == 0 || newCollateral == 0) return;
        uint256 lev = newSize / newCollateral;
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        require(lev <= $.config[market].maxLeverage, "MarketValid:Lev");
        require(lev >= $.config[market].minLeverage, "MarketValid:Lev");
    }

    // //================================================================================================
    // // position
    // //================================================================================================

    function validPayMax(uint16 market, uint256 pay) internal view {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        require(pay <= $.config[market].maxTradeAmount, "MarketValid:pay>MaxTradeAmount");
    }

    function validPosition(MarketCache memory _params, PositionProps memory _position, int256 totalFees)
        internal
        view
    {
        validSize(_position.size, _params.sizeDelta, _params.isOpen);
        if (_params.isOpen) {
            validPayMax(_params.market, _params.collateralDelta);
            _params.busiType =
                _params.sizeDelta > 0 ? MarketBusinessType.Increase : MarketBusinessType.IncreaseCollateral;
            validCollateralDelta(
                _params.busiType,
                _params.market,
                _position.collateral,
                _params.collateralDelta,
                _position.size,
                _params.sizeDelta,
                totalFees
            );
        } else {
            _params.busiType =
                _params.sizeDelta > 0 ? MarketBusinessType.Decrease : MarketBusinessType.DecreaseCollateral;
            if (_params.sizeDelta != _position.size) {
                validCollateralDelta(
                    _params.busiType,
                    _params.market,
                    _position.collateral,
                    _params.collateralDelta,
                    _position.size,
                    _params.sizeDelta,
                    totalFees
                );
            }
        }
        if (_params.sizeDelta > 0 && _params.liqState == LiquidationState.None) {
            require(_params.oraclePrice > 0, "invalid oracle price");
            validSlippagePrice(_params);
        }
    }

    function validateLiquidation(uint16 market, int256 fees, int256 liquidateFee, bool raise)
        internal
        view
        returns (uint8)
    {
        // todo
    }

    // //================================================================================================
    // // order
    // //================================================================================================

    function validIncreaseOrder(MarketCache memory _vars, int256 fees) internal view {
        validSize(0, _vars.sizeDelta, true);
        validCollateralDelta(
            MarketBusinessType.IncreaseCollateral, _vars.market, 0, _vars.pay, 0, _vars.sizeDelta, fees
        );
    }

    function validDecreaseOrder(
        uint16 market,
        uint256 collateral,
        uint256 collateralDelta,
        uint256 size,
        uint256 sizeDelta,
        int256 fees,
        uint256 decrOrderCount
    ) internal view {
        MarketHandler.StorageStruct storage conf = MarketHandler.Storage();
        require(conf.config[market].decreaseNumLimit >= decrOrderCount + 1, "Max orders:config limit");
        validSize(size, sizeDelta, false);
        if (conf.config[market].validDecrease) {
            validCollateralDelta(
                MarketBusinessType.Decrease, market, collateral, collateralDelta, size, sizeDelta, fees
            );
        }
    }

    function validCollateralDelta(
        MarketBusinessType busType,
        uint16 market,
        uint256 _collateral,
        uint256 _collateralDelta,
        uint256 _size,
        uint256 _sizeDelta,
        int256 _fees
    ) internal view {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        if (
            (!$.config[market].allowOpen && busType <= MarketBusinessType.IncreaseCollateral)
                || (!$.config[market].allowClose && busType >= MarketBusinessType.Decrease)
        ) {
            revert("MarketValid:MarketClosed");
        }
        if (busType >= MarketBusinessType.Decrease && _sizeDelta == _size) return;
        uint256 newCollateral = (
            busType <= MarketBusinessType.IncreaseCollateral
                ? (_collateral + _collateralDelta)
                : (_collateral - _collateralDelta)
        );
        if (busType == MarketBusinessType.Decrease && newCollateral == 0) return;
        if (busType <= MarketBusinessType.IncreaseCollateral) {
            if (_fees > 0) newCollateral -= uint256(_fees);
            else newCollateral += uint256(-_fees);
        }
        require(_collateral > 0, "MarketValid:Collateral");
        require(busType != MarketBusinessType.Increase, "MarketValid:Collateral");
        require(_collateralDelta >= $.config[market].minPayment, "MarketValid:Collateral");
    }

    function validOrderAccountAndID(OrderProps memory order) internal pure {
        require(order.account != address(0), "invalid order key");
        require(order.orderID != 0, "invalid order key");
    }

    function validTPSL(OrderProps memory _order, bool _isLong) internal pure {
        // remove valid tp sl in order book
        if (_order.tp > 0) {
            if (_order.tp > _order.price != _isLong || _order.tp == _order.price) {
                revert("MarketValid:Tp");
            }
        }
        if (_order.sl > 0) {
            if (_isLong != _order.price > _order.sl || _order.sl == _order.price) {
                revert("MarketValid:Sl");
            }
        }
    }

    // //================================================================================================
    // // private
    // //================================================================================================

    function validMarkPrice(MarketCache memory _inputs) private pure {
        require(_inputs.oraclePrice > 0, "MarketValid:!oracle");
        require(
            _inputs.isExec || ((_inputs.isLong == _inputs.isOpen) == (_inputs.price > _inputs.oraclePrice)),
            "MarketValid:!front-end price"
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function validSlippagePrice(MarketCache memory _inputs) private view {
        MarketHandler.StorageStruct storage $ = MarketHandler.Storage();
        _inputs.slippage = min(_inputs.slippage, $.config[_inputs.market].maxSlippage);
        uint256 _slippagePrice;
        uint256 slipageValue = _inputs.price.percentMul(_inputs.slippage);
        if (_inputs.isLong == _inputs.isOpen) {
            _slippagePrice = _inputs.price + slipageValue;
        } else {
            _slippagePrice = _inputs.price - slipageValue;
        }
        require(_slippagePrice > 0, "MarketValid:input price zero");
        validMarkPrice(_inputs);
    }

    function validSize(uint256 _size, uint256 _sizeDelta, bool isOpen) private pure {
        // size should greater than size delta when decrease position
        require(isOpen || _size >= _sizeDelta, "MarketValid:Size");
    }
}
