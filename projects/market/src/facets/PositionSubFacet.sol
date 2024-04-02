// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {StringsPlus} from "../lib/utils/Strings.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {PositionSubMgrLib} from "../lib/market/PositionSubMgrLib.sol";
//===============
// interfaces

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {IVault} from "../interfaces/IVault.sol";

//===============
// data types
import {Order} from "../lib/types/OrderStruct.sol";

import {Position} from "../lib/types/PositionStruct.sol";
import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";

import {FeeType} from "../lib/types/FeeType.sol";
//===============
// handlers
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {OrderHandler} from "../lib/order/OrderHandler.sol";
import {PositionFacetBase} from "./PositionFacetBase.sol";
import {BalanceHandler} from "../lib/balance/BalanceHandler.sol";
import {PositionStorage} from "../lib/position/PositionStorage.sol";

contract PositionSubFacet is IAccessManaged, PositionFacetBase {
    using Order for Order.Props;
    using SafeCast for int256;
    using SafeCast for uint256;
    using PositionSubMgrLib for MarketDataTypes.Cache;
    //==========================================================================================
    //       external functions
    //==========================================================================================

    //==========================================================================================
    //       self functions
    //==========================================================================================

    //==========================================================================================
    //       admin functions
    //==========================================================================================
    function liquidate(uint16 market, address accounts, bool _isLong) external restricted {}

    function execSubOrderKey(Order.Props memory order, MarketDataTypes.Cache memory _params) external restricted {
        order.validOrderAccountAndID();
        require(_params.isOpen == false, "PositionSubMgr:invalid isOpen");
        uint256 oraclePrice;
        Position.Props memory _position =
            PositionStorage.getPosition(_params.market, order.account, oraclePrice, _params.isLong);
        (int256[] memory fees, int256 totalFee) = _feeFacet().getFees(abi.encode(_params, _position));
        MarketHandler.validateLiquidation(_params.market, totalFee, fees[uint8(FeeType.T.LiqFee)], true);
        decreasePositionFromOrder(order, _params);
    }
    //==========================================================================================
    //       view functions
    //==========================================================================================

    function validLiq(address acc, bool _isLong) private view {}

    //==========================================================================================
    //       private functions
    //==========================================================================================

    function _getClosePrice(uint16 market, bool _isLong) private view returns (uint256 p) {
        return _priceFacet().getPrice(market, !_isLong);
    }

    function decreasePositionFromOrder(Order.Props memory order, MarketDataTypes.Cache memory _params) private {
        _params.oraclePrice = _getClosePrice(_params.market, _params.isLong);

        Position.Props memory _position =
            PositionStorage.getPosition(_params.market, order.account, _params.oraclePrice, _params.isLong);

        if (order.size > 0) {
            _params.collateralDelta = PositionSubMgrLib.getDecreaseDeltaCollateral(
                order.isKeepLev, _position.size, order.size, _position.collateral
            );
        }

        Order.Props[] memory ods =
            OrderHandler.remove(_params.market, _params.isOpen, _params.isLong, order.account, order.orderID);
        require(ods[0].account != address(0), "PositionSubMgr:!account");

        // , emit
        for (uint256 i = 0; i < ods.length; i++) {
            Order.Props memory od = ods[i];
            if (address(0) == od.account) continue;
            // MarketLib.afterDeleteOrder(
            //     MarketOrderCallBackIntl.DeleteOrderEvent(
            //         od,
            //         _params,
            //         uint8(i == 0 ? CancelReason.Executed : CancelReason.TpAndSlExecuted), // Executed, TpAndSlExecuted, 3, 4
            //         "",
            //         i == 0
            //             ? (_position.realisedPnl * _params.sizeDelta.toInt256()) / _position.size.toInt256()
            //             : int256(0)
            //     ),
            //     pluginGasLimit,
            //     plugins,
            //     collateralToken,
            //     address(this)
            // );
            if (i == 0) {
                _params.execNum += 1;
                require(
                    od.isMarkPriceValid(_params.oraclePrice),
                    order.isFromMarket ? "PositionSubMgr:market slippage" : StringsPlus.POSITION_TRIGGER_ABOVE
                );
            }
        }

        _decreasePosition(_params, _position);
    }

    function _decreasePosition(MarketDataTypes.Cache memory _params, Position.Props memory _position) private {
        // Return if the position size is zero or the account is invalid
        if (_position.size == 0 || _params.account == address(0)) return;

        // Update the cumulative funding rate
        _updateCumulativeFundingRate(_params.market);

        // Check if the position is being closed entirely
        bool isCloseAll = _position.size == _params.sizeDelta;

        if (isCloseAll) {
            // Determine the cancellation reason based on the liquidation state
            MarketHandler.CancelReason reason = MarketHandler.CancelReason.PositionClosed;
            if (_params.liqState == 1) {
                reason = MarketHandler.CancelReason.Liquidation;
            } else if (_params.liqState == 2) {
                reason = MarketHandler.CancelReason.LeverageLiquidation;
            }

            // Remove orders associated with the account
            Order.Props[] memory _ordersDeleted =
                OrderHandler.removeByAccount(_params.market, false, _params.isLong, _params.account);

            // Iterate over the deleted orders and perform necessary actions
            for (uint256 i = 0; i < _ordersDeleted.length; i++) {
                Order.Props memory _orderDeleted = _ordersDeleted[i];
                if (_orderDeleted.account == address(0)) {
                    continue;
                }
                _params.execNum += 1;

                // Perform actions after deleting the order
                // MarketLib.afterDeleteOrder(
                //     MarketOrderCallBackIntl.DeleteOrderEvent(_orderDeleted, _params, uint8(reason), "", 0),
                //     pluginGasLimit,
                //     plugins,
                //     collateralToken,
                //     address(this)
                // );
            }
        }

        (int256[] memory _originFees, int256 totalFees) = _feeFacet().getFees(abi.encode(_params, _position));

        if (_params.sizeDelta == 0) {
            uint256 collateral =
                totalFees <= 0 ? (_position.collateral.toInt256() - totalFees).toUint256() : _position.collateral;
            MarketHandler.validCollateralDelta(abi.encode(4, collateral, _params.collateralDelta, _position.size, 0, 0));
        } else {
            MarketHandler.validPosition(abi.encode(_params, _position, _originFees));
        }

        int256 dPnl;
        if (_params.sizeDelta > 0) {
            dPnl = _positionFacet().getPNL(
                _params.market, _params.account, _params.sizeDelta, _params.oraclePrice, _params.isLong
            );
        }
        _position.realisedPnl = dPnl;

        // >>>>>>>>>>>>>>>>>>>>>>>>>开始转账
        PositionSubMgrLib.DecreaseTransactionOuts memory _outs =
            _decreaseTransaction(_params, _position, dPnl, _originFees);
        // <<<<<<<<<<<<<<<<<<<<<<<<<<转账结束

        // >>>>>>>>>>>>>>>>>>>>>仓位修改
        //                     获取现在的累计资金费率
        int256 _nowFundRate = _feeFacet().cumulativeFundingRates(_params.market, _params.isLong);
        //                     先把资金费结算给用户
        if (_outs.newCollateralUnsigned > 0 && _outs.withdrawFromFeeVault > 0) {
            _positionFacet().increasePosition(
                abi.encode(
                    _params.account,
                    _outs.withdrawFromFeeVault,
                    0, //sizeDelta
                    _params.oraclePrice,
                    _nowFundRate,
                    _params.isLong
                )
            );
        }

        // >>>>>>>>>>>>>>>>>>>>>>偿还 CoreVault 的账目
        address colleteralToken = MarketHandler.collateralToken(_params.market);
        vault(_params.market).repayToVault(
            _params.market,
            _marketFacet().formatCollateral(_params.sizeDelta, IERC20Metadata(colleteralToken).decimals())
        );
        Position.Props memory result = _positionFacet().decreasePosition(
            abi.encode(_params.account, _outs.collateralDecreased, _params.sizeDelta, _nowFundRate, _params.isLong)
        );
        // <<<<<<<<<<<<<<<<<<仓位修改

        MarketHandler.validLev(_params.market, result.size, result.collateral);

        if (PositionSubMgrLib.isClearPos(_params, _position)) {
            validLiq(_params.account, _params.isLong);
        }

        // MarketLib.afterUpdatePosition(
        //     MarketPositionCallBackIntl.UpdatePositionEvent(
        //         _params, _position, _originFees, collateralToken, indexToken, _outs.collateralDeltaAfter
        //     ),
        //     pluginGasLimit,
        //     plugins,
        //     collateralToken,
        //     address(this)
        // );
    }

    function _decreaseTransaction(
        MarketDataTypes.Cache memory _params,
        Position.Props memory _position,
        int256 dPNL,
        int256[] memory _originFees
    ) private returns (PositionSubMgrLib.DecreaseTransactionOuts memory _outs) {
        //================================================
        //                  Calc
        //================================================
        _outs = _params.calDecreaseTransactionValues(_position, dPNL, _originFees);
        uint256 fundfeeLoss = PositionSubMgrLib.calculateFundFeeLoss(_position.collateral.toInt256(), dPNL, _originFees);

        //================================================
        //            fee vault transactions
        //================================================
        address _collateralToken = MarketHandler.collateralToken(_params.market);
        IERC20Metadata _collateralTokenERC20 = IERC20Metadata(_collateralToken);
        uint256 amount = _marketFacet().formatCollateral(
            _outs.transToFeeVault >= 0 ? _outs.transToFeeVault.toUint256() : (-_outs.transToFeeVault).toUint256(),
            _collateralTokenERC20.decimals()
        );

        if (_outs.transToFeeVault >= 0) {
            //todo
            // BalanceHandler.marketToFee(_params.market, _params.account, _outs.transToFeeVault);
            // feeRouter.collectFees(_params.account, _collateralToken, _originFees, fundfeeLoss);
        } else {
            //todo
            // BalanceHandler.feeToMarket(_params.market, _params.account, _originFees, amount);
            // feeRouter.payoutFees(_params.account, _collateralToken, _originFees, amount);
        }

        //================================================
        // vault transactions
        //================================================
        // if (_outs.transToVault > 0) {
        //     _transferToVault(_collateralTokenERC20, uint256(_outs.transToVault));
        // } else {
        //     MarketLib.vaultWithdraw(
        //         _collateralToken, address(this), -_outs.transToVault, collateralTokenDigits, vaultRouter
        //     );
        // }
        //================================================
        //         usr transactions
        //================================================
        if (_outs.transToUser > 0) {
            _marketFacet().transferOut(_collateralToken, _params.account, uint256(_outs.transToUser));
        }
    }
}
