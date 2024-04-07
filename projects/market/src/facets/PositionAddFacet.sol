// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import {Validations} from "../lib/types/Valid.sol";
import {OrderHelper} from "../lib/order/OrderHelper.sol";
//===============
// interfaces
import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {PositionFacetBase, IncreasePositionInputs, DecreasePositionInputs} from "./PositionFacetBase.sol";
//===============
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {StringsPlus} from "../lib/utils/Strings.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./funcs.sol";
//===============
// data types
import "../lib/types/Types.sol";
import {Event} from "../lib/types/Event.sol";
// //===============
// // handlers
import {GValidHandler} from "../lib/globalValid/GValidHandler.sol";
import {PositionStorage} from "../lib/position/PositionStorage.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {OrderHandler} from "../lib/order/OrderHandler.sol";

contract PositionAddFacet is IAccessManaged, PositionFacetBase {
    using Validations for OrderProps;
    using SafeCast for int256;
    using SafeCast for uint256;

    //==========================================================================================
    //       admin functions
    //==========================================================================================

    function execAddOrder(OrderProps memory order, MarketCache memory _params) external restricted {
        _params.oraclePrice = _getOpenPrice(_params.market, _params.isLong);
        if (0 == _params.slippage && 0 == _params.fromOrder) {
            _params.slippage = 30;
        }

        // ------------
        // validations
        require(_params.isOpen, "PositionAddMgr:invalid isopen");
        require(_params.collateralDelta == order.collateral, "PositionAddMgr: insufficient collateral");
        Validations.validOrderAccountAndID(order);
        require(
            OrderHelper.isMarkPriceValid(order, _params.oraclePrice),
            order.isFromMarket ? "PositionAddMgr:market slippage" : StringsPlus.POSITION_TRIGGER_ABOVE
        );
        validateIncreasePosition(_params);

        // ------------
        // cancel order
        _orderFacet().cancelOrder(order.account, _params.market, _params.isOpen, order.orderID, _params.isLong);
        _params.execNum += 1;
        emit Event.DeleteOrder(
            order.account,
            _params.isLong,
            _params.isOpen,
            order.orderID,
            _params.market,
            uint8(CancelReason.Executed),
            "",
            _params.oraclePrice,
            int256(0)
        );

        // TODO call referrals
        // if (false == _params.isValid()) {
        //     if (_params.isExec) return;
        //     else revert("PositionAddMgr:invalid params");
        // }

        // ------------
        // increase position
        PositionProps memory _position = PositionStorage.getPosition(
            _params.market, _params.account, _params.sizeDelta == 0 ? 0 : _params.oraclePrice, _params.isLong
        );

        int256 collateralChanged = _increasePosition(_params, _position);
        if (collateralChanged < 0) collateralChanged = 0;

        // ------------
        // create decrease order
        bool shouldCreateDecreaseOrder = MarketHandler.getDecreaseOrderValidation(
            _params.market, OrderHandler.getOrderNum(_params.market, _params.isLong, _params.isOpen, _params.account)
        );
        if (false == shouldCreateDecreaseOrder || _params.sizeDelta == 0) {
            return;
        }
        bool placeTp = _params.tp != 0 && (_params.tp > _params.price == _params.isLong || _params.tp == _params.price);
        bool placeSl = _params.sl != 0 && (_params.isLong == _params.price > _params.sl || _params.price == _params.sl);
        MarketCache[] memory _vars;
        uint256 ordersCount = placeTp && placeSl ? 2 : (placeTp || placeSl ? 1 : 0);
        if (ordersCount > 0) {
            _vars = new MarketCache[](ordersCount);
            _vars[0] =
                _buildDecreaseVars(_params, uint256(collateralChanged), placeTp ? _params.tp : _params.sl, placeTp);

            if (ordersCount == 2) {
                _vars[1] = _buildDecreaseVars(_params, uint256(collateralChanged), _params.sl, false);
            }
        } else {
            return;
        }

        OrderProps[] memory _os = _orderFacet().addOrders(_vars);
        // uint256[] memory inputs = new uint256[](0);
        // for (uint256 i; i < _os.length;) {
        //     OrderProps memory _order = _os[i];

        //     MarketLib.afterUpdateOrder(
        //         MarketDataTypes.UpdateOrderInputs({
        //             _market: address(this),
        //             _isLong: _params.isLong,
        //             _oraclePrice: _params.oraclePrice,
        //             isOpen: false,
        //             isCreate: true,
        //             _order: _order,
        //             inputs: inputs
        //         }),
        //         pluginGasLimit,
        //         plugins,
        //         collateralToken,
        //         address(this)
        //     );

        //     unchecked {
        //         ++i;
        //     }
        // }
    }

    //==========================================================================================
    //       view functions
    //==========================================================================================
    function getMarketsOfMarket(uint16 market) public view returns (uint256[] memory) {
        address _vault = MarketHandler.Storage().vault[market];
        return EnumerableSet.values(MarketHandler.Storage().marketIds[_vault]);
    }

    function getGlobalSize(uint16 market) public view returns (uint256 sizesLong, uint256 sizesShort) {
        uint256[] memory ids = getMarketsOfMarket(market);
        for (uint256 i = 0; i < ids.length; i++) {
            (uint256 l, uint256 s) = PositionStorage.getMarketSizesForBothDirections(uint16(ids[i]));
            sizesLong += l;
            sizesShort += s;
        }
    }

    function getAccountSizeOfMarkets(uint16 market, address account)
        public
        view
        returns (uint256 sizesL, uint256 sizesS)
    {
        uint256[] memory ids = getMarketsOfMarket(market);
        for (uint256 i = 0; i < ids.length; i++) {
            (uint256 l, uint256 s) = PositionStorage.getAccountSizesForBothDirections(uint16(ids[i]), account);
            sizesL += l;
            sizesS += s;
        }
    }

    //==========================================================================================
    //       private functions
    //==========================================================================================

    function validateIncreasePosition(MarketCache memory _params) private view {
        GValid memory params;
        params.market = _params.market;
        params.isLong = _params.isLong;
        params.sizeDelta = _params.sizeDelta;

        (params.globalLongSizes, params.globalShortSizes) = getGlobalSize(_params.market);
        (params.userLongSizes, params.userShortSizes) = getAccountSizeOfMarkets(params.market, _params.account);
        (params.marketLongSizes, params.marketShortSizes) =
            PositionStorage.getMarketSizesForBothDirections(params.market);
        address _collateralToken = MarketHandler.collateralToken(_params.market);
        params.aum = parseVaultAsset(vault(_params.market).getAUM(), _collateralToken);
        require(GValidHandler.isIncreasePosition(params), "mr:gv");
    }

    function _buildDecreaseVars(
        MarketCache memory _params,
        uint256 collateralIncreased,
        uint256 triggerPrice,
        bool isTP
    ) private view returns (MarketCache memory _createVars) {
        _createVars.market = _params.market;
        _createVars.isLong = _params.isLong;
        _createVars.oraclePrice = _getClosePrice(_params.market, _params.isLong);
        _createVars.isCreate = true;

        _createVars.fromOrder = _params.fromOrder;
        _createVars.account = _params.account;
        _createVars.sizeDelta = _params.sizeDelta;
        _createVars.collateral = 0; // painter0

        if ((isTP && _params.isKeepLevTP) || (false == isTP && _params.isKeepLevSL)) {
            _createVars.collateral = collateralIncreased;
            _createVars.isKeepLev = true;
        }
        _createVars.triggerAbove = isTP == _params.isLong;
        _createVars.price = triggerPrice;
        _createVars.refCode = _params.refCode;
    }

    function _increasePosition(MarketCache memory _params, PositionProps memory _position)
        private
        returns (int256 collD)
    {
        _updateCumulativeFundingRate(_params.market);

        (int256[] memory _fees, int256 _totalfee) = _feeFacet().getFeesReceivable(_params, _position);

        if (_params.sizeDelta > 0) {
            Validations.validPosition(_params, _position, _totalfee);
        } else {
            Validations.validCollateralDelta(
                MarketBusinessType.IncreaseCollateral,
                _params.market,
                _position.collateral,
                _params.collateralDelta,
                _position.size,
                0,
                _totalfee
            );
        }
        int256 _fundingRate = _feeFacet().cumulativeFundingRates(_params.market, _params.isLong);
        collD = _params.collateralDelta.toInt256() - _totalfee;
        commitIncreasePosition(_params, collD, _fundingRate);
        // (_params.account, _params.isLong);
        // _transationsFees(_params.account, collateralToken, _fees, _totalfee); // 手续费转账
        // MarketLib.afterUpdatePosition(
        //     MarketPositionCallBackIntl.UpdatePositionEvent(
        //         _params, _position, _fees, collateralToken, indexToken, collD
        //     ),
        //     pluginGasLimit,
        //     plugins,
        //     collateralToken,
        //     address(this)
        // );
    }

    function commitIncreasePosition(MarketCache memory _params, int256 collD, int256 fr)
        private
        returns (PositionProps memory result)
    {
        if (_params.sizeDelta == 0 && collD < 0) {
            // abi.encode(_params.account, uint256(-collD), _params.sizeDelta, fr, _params.isLong)
            result = _positionFacet().decreasePosition(
                DecreasePositionInputs({
                    market: _params.market,
                    account: _params.account,
                    collateralDelta: collD,
                    sizeDelta: _params.sizeDelta,
                    fundingRate: fr,
                    isLong: _params.isLong
                })
            );
        } else {
            address collateralToken = MarketHandler.collateralToken(_params.market);

            vault(_params.market).borrowFromVault(_params.market, formatCollateral(_params.sizeDelta, collateralToken));
            result = _positionFacet().increasePosition(
                IncreasePositionInputs({
                    market: _params.market,
                    account: _params.account,
                    collateralDelta: collD,
                    sizeDelta: _params.sizeDelta,
                    markPrice: _params.oraclePrice,
                    fundingRate: fr,
                    isLong: _params.isLong
                })
            );
        }
        //PositionProps
        Validations.validLev(_params.market, result.size, result.collateral);
    }
}
