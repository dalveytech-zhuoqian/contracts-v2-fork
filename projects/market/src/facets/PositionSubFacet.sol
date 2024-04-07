// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import "./funcs.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {StringsPlus} from "../lib/utils/Strings.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {PositionSubMgrLib} from "../lib/market/PositionSubMgrLib.sol";

//===============
// data types
import "../lib/types/Types.sol";
//===============
// handlers
import {MarketHandler} from "../lib/market/MarketHandler.sol";

import {Validations} from "../lib/types/Valid.sol";
import {OrderHandler, OrderHelper} from "../lib/order/OrderHandler.sol";
import {BalanceHandler} from "../lib/balance/BalanceHandler.sol";
import {PositionStorage} from "../lib/position/PositionStorage.sol";
//===============
// interfaces
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {PositionFacetBase, DecreasePositionInputs, IncreasePositionInputs} from "./PositionFacetBase.sol";

contract PositionSubFacet is IAccessManaged, PositionFacetBase {
    using OrderHelper for OrderProps;
    using SafeCast for int256;
    using SafeCast for uint256;
    using PositionSubMgrLib for MarketCache;
    // //==========================================================================================
    // //       external functions
    // //==========================================================================================

    // //==========================================================================================
    // //       self functions
    // //==========================================================================================

    // //==========================================================================================
    // //       admin functions
    // //==========================================================================================
    function liquidate(uint16 market, address accounts, bool _isLong) external restricted {}

    function execSubOrder(OrderProps memory order, MarketCache memory _params) external restricted {
        _params.oraclePrice = _getClosePrice(_params.market, _params.isLong);
        PositionProps memory _position =
            PositionStorage.getPosition(_params.market, order.account, _params.oraclePrice, _params.isLong);
        (int256[] memory fees, int256 totalFee) = _feeFacet().getFeesReceivable(_params, _position);
        if (order.size > 0) {
            _params.collateralDelta =
                getDecreaseDeltaCollateral(order.isKeepLev, _position.size, order.size, _position.collateral);
        }

        //--------------
        // validations
        Validations.validOrderAccountAndID(order);
        require(_params.isOpen == false, "PositionSubMgr:invalid isOpen");
        Validations.validateLiquidation(_params.market, totalFee, fees[uint8(FeeType.LiqFee)], true);

        //--------------
        // cancel order
        OrderProps[] memory ods =
            _orderFacet().cancelOrder(_params.account, _params.market, _params.isOpen, order.orderID, _params.isLong);

        for (uint256 i = 0; i < ods.length; i++) {
            OrderProps memory od = ods[i];
            if (address(0) == od.account) continue;
            // todo call referral
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
                // require(
                // od.isMarkPriceValid(_params.oraclePrice),
                //     order.isFromMarket ? "PositionSubMgr:market slippage" : StringsPlus.POSITION_TRIGGER_ABOVE
                // );
            }
        }
        _decreasePosition(_params, _position);
    }

    // //==========================================================================================
    // //       private functions
    // //==========================================================================================

    function _decreasePosition(MarketCache memory _params, PositionProps memory _position) private {
        // Return if the position size is zero or the account is invalid
        if (_position.size == 0 || _params.account == address(0)) return;

        // Update the cumulative funding rate
        _updateCumulativeFundingRate(_params.market);

        // Check if the position is being closed entirely
        bool isCloseAll = _position.size == _params.sizeDelta;

        if (isCloseAll) {
            // Determine the cancellation reason based on the liquidation state
            CancelReason reason = CancelReason.PositionClosed;
            if (_params.liqState == LiquidationState.Collateral) {
                reason = CancelReason.Liquidation;
            } else if (_params.liqState == LiquidationState.Leverage) {
                reason = CancelReason.LeverageLiquidation;
            }

            // Remove orders associated with the account
            OrderProps[] memory _ordersDeleted =
                OrderHandler.removeByAccount(_params.market, false, _params.isLong, _params.account);

            // Iterate over the deleted orders and perform necessary actions
            for (uint256 i = 0; i < _ordersDeleted.length; i++) {
                OrderProps memory _orderDeleted = _ordersDeleted[i];
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

        (int256[] memory _originFees, int256 totalFees) = _feeFacet().getFeesReceivable(_params, _position);

        if (_params.sizeDelta == 0) {
            uint256 collateral =
                totalFees <= 0 ? (_position.collateral.toInt256() - totalFees).toUint256() : _position.collateral;
            // Validations.validCollateralDelta(abi.encode(4, collateral, _params.collateralDelta, _position.size, 0, 0));
        } else {
            // Validations.validPosition(_params, _position, _originFees);
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
                IncreasePositionInputs({
                    market: _params.market,
                    account: _params.account,
                    collateralDelta: _outs.withdrawFromFeeVault,
                    sizeDelta: 0,
                    markPrice: _params.oraclePrice,
                    fundingRate: _nowFundRate,
                    isLong: _params.isLong
                })
            );
        }

        // >>>>>>>>>>>>>>>>>>>>>>偿还 CoreVault 的账目
        address colleteralToken = MarketHandler.collateralToken(_params.market);
        vault(_params.market).repayToVault(_params.market, formatCollateral(_params.sizeDelta, colleteralToken));
        PositionProps memory result = _positionFacet().decreasePosition(
            DecreasePositionInputs({
                market: _params.market,
                account: _params.account,
                collateralDelta: int256(_outs.collateralDecreased),
                sizeDelta: _params.sizeDelta,
                fundingRate: _nowFundRate,
                isLong: _params.isLong
            })
        );
        // <<<<<<<<<<<<<<<<<<仓位修改

        Validations.validLev(_params.market, result.size, result.collateral);

        if (PositionSubMgrLib.isClearPos(_params, _position)) {
            // validLiq(_params.account, _params.isLong);
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
        MarketCache memory _params,
        PositionProps memory _position,
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
        // IERC20Metadata _collateralTokenERC20 = IERC20Metadata(_collateralToken);
        uint256 amount = formatCollateral(
            _outs.transToFeeVault >= 0 ? _outs.transToFeeVault.toUint256() : (-_outs.transToFeeVault).toUint256(),
            _collateralToken
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
            transferOut(_collateralToken, _params.account, uint256(_outs.transToUser));
        }
    }
}
