// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {StringsPlus} from "../lib/utils/Strings.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
//===============
// interfaces
import {IFeeFacet} from "../interfaces/IFeeFacet.sol";
import {IMarketInternal} from "../interfaces/IMarketInternal.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {IVault} from "../interfaces/IVault.sol";
import {IPrice} from "../interfaces/IPrice.sol";
//===============
// data types
import {Order} from "../lib/types/OrderStruct.sol";

import {GDataTypes} from "../lib/types/GDataTypes.sol";
import {Position} from "../lib/types/PositionStruct.sol";
import {MarketDataTypes} from "../lib/types/MarketDataTypes.sol";
//===============
// handlers
import {GValidHandler} from "../lib/globalValid/GValidHandler.sol";
import {PositionHandler} from "../lib/position/PositionHandler.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";
import {OrderHandler} from "../lib/order/OrderHandler.sol";

contract PositionAddFacet is IAccessManaged {
    using Order for Order.Props;
    using SafeCast for int256;
    using SafeCast for uint256;

    function _feeFacet() internal view returns (IFeeFacet) {
        return IFeeFacet(address(this));
    }

    function _marketFacet() internal view returns (IMarketInternal) {
        return IMarketInternal(address(this));
    }

    function _priceFacet() internal view returns (IPrice) {
        return IPrice(address(this));
    }

    function commitIncreasePosition(MarketDataTypes.Cache memory _params, int256 collD, int256 fr)
        private
        returns (Position.Props memory result)
    {
        if (_params.sizeDelta == 0 && collD < 0) {
            result = PositionHandler.decreasePosition(
                abi.encode(_params.account, uint256(-collD), _params.sizeDelta, fr, _params.isLong)
            );
        } else {
            address vault = MarketHandler.Storage().vault[_params.market];
            address collateralToken = MarketHandler.collateralToken(_params.market);
            IVault(vault).borrowFromVault(
                _params.market,
                _marketFacet().formatCollateral(_params.sizeDelta, IERC20Metadata(collateralToken).decimals())
            );
            result = PositionHandler.increasePosition(
                abi.encode(_params.account, collD, _params.sizeDelta, _params.oraclePrice, fr, _params.isLong)
            );
        }
        //Position.Props
        MarketHandler.validLev(_params.market, result.size, result.collateral);
    }

    function execAddOrderKey(Order.Props memory exeOrder, MarketDataTypes.Cache memory _params) external restricted {
        Order.validOrderAccountAndID(exeOrder);
        require(_params.isOpen, "PositionAddMgr:invalid isopen");
        _execIncreaseOrderKey(exeOrder, _params);
    }

    function getMarketsOfMarket(uint16 market) internal view returns (uint256[] memory) {
        address vault = MarketHandler.Storage().vault[market];
        return EnumerableSet.values(MarketHandler.Storage().marketIds[vault]);
    }

    function getGlobalSize(uint16 market) public view returns (uint256 sizesLong, uint256 sizesShort) {
        uint256[] memory ids = getMarketsOfMarket(market);
        for (uint256 i = 0; i < ids.length; i++) {
            (uint256 l, uint256 s) = PositionHandler.getMarketSizes(uint16(ids[i]));
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
            (uint256 l, uint256 s) = PositionHandler.getAccountSize(uint16(ids[i]), account);
            sizesL += l;
            sizesS += s;
        }
    }

    function _execIncreaseOrderKey(Order.Props memory order, MarketDataTypes.Cache memory _params) private {
        _params.oraclePrice = _priceFacet().getPrice(_params.market, _params.isLong);
        require(order.account != address(0), "PositionAddMgr:!account");
        validateIncreasePosition(_params);

        OrderHandler.remove(_params.market, _params.isOpen, _params.isLong, order.account, order.orderID);
        _params.execNum += 1;
        require(
            order.isMarkPriceValid(_params.oraclePrice),
            order.isFromMarket ? "PositionAddMgr:market slippage" : StringsPlus.POSITION_TRIGGER_ABOVE
        );

        require(_params.collateralDelta == order.collateral, "PositionAddMgr: insufficient collateral");

        emit OrderHandler.DeleteOrder(
            order.account,
            _params.isLong,
            _params.isOpen,
            order.orderID,
            _params.market,
            uint8(MarketHandler.CancelReason.Executed),
            "",
            _params.oraclePrice,
            int256(0)
        );
        // TODO call referrals
        increasePositionWithOrders(_params);
    }

    function validateIncreasePosition(MarketDataTypes.Cache memory _inputs) private view {
        GDataTypes.ValidParams memory params;
        params.market = _inputs.market;
        params.isLong = _inputs.isLong;
        params.sizeDelta = _inputs.sizeDelta;

        (params.globalLongSizes, params.globalShortSizes) = getGlobalSize(_inputs.market);
        (params.userLongSizes, params.userShortSizes) = getAccountSizeOfMarkets(params.market, _inputs.account);
        (params.marketLongSizes, params.marketShortSizes) = PositionHandler.getMarketSizes(params.market);
        address _collateralToken = MarketHandler.collateralToken(_inputs.market);
        address vault = MarketHandler.Storage().vault[_inputs.market];
        params.aum = _marketFacet().parseVaultAsset(IVault(vault).getAUM(), IERC20Metadata(_collateralToken).decimals());
        require(GValidHandler.isIncreasePosition(params), "mr:gv");
    }

    function increasePositionWithOrders(MarketDataTypes.Cache memory _inputs) public {
        // if (false == _inputs.isValid()) {
        //     if (_inputs.isExec) return;
        //     else revert("PositionAddMgr:invalid params");
        // }
        MarketHandler.validPay(_inputs.market, _inputs.collateralDelta);

        if (_inputs.slippage == 0 && 0 == _inputs.fromOrder) {
            _inputs.slippage = 30;
        }

        _inputs.oraclePrice = _priceFacet().getPrice(_inputs.market, _inputs.isLong);
        Position.Props memory _position = PositionHandler.getPosition(
            _inputs.account, _inputs.market, _inputs.sizeDelta == 0 ? 0 : _inputs.oraclePrice, _inputs.isLong
        );

        int256 collateralChanged = _increasePosition(_inputs, _position);
        if (collateralChanged < 0) collateralChanged = 0;

        bool shouldCreateDecreaseOrder = MarketHandler.getDecreaseOrderValidation(
            _inputs.market, OrderHandler.orderNum(_inputs.market, _inputs.isLong, _inputs.isOpen, _inputs.account)
        );

        if (false == shouldCreateDecreaseOrder || _inputs.sizeDelta == 0) {
            return;
        }

        bool placeTp = _inputs.tp != 0 && (_inputs.tp > _inputs.price == _inputs.isLong || _inputs.tp == _inputs.price);

        bool placeSl = _inputs.sl != 0 && (_inputs.isLong == _inputs.price > _inputs.sl || _inputs.price == _inputs.sl);

        MarketDataTypes.Cache[] memory _vars;
        uint256 ordersCount = placeTp && placeSl ? 2 : (placeTp || placeSl ? 1 : 0);
        if (ordersCount > 0) {
            _vars = new MarketDataTypes.Cache[](ordersCount);
            _vars[0] =
                _buildDecreaseVars(_inputs, uint256(collateralChanged), placeTp ? _inputs.tp : _inputs.sl, placeTp);

            if (ordersCount == 2) {
                _vars[1] = _buildDecreaseVars(_inputs, uint256(collateralChanged), _inputs.sl, false);
            }
        } else {
            return;
        }

        // Order.Props[] memory _os = (_inputs.isLong ? orderBookLong : orderBookShort).add(_vars);
        // uint256[] memory inputs = new uint256[](0);
        // for (uint256 i; i < _os.length;) {
        //     Order.Props memory _order = _os[i];

        //     MarketLib.afterUpdateOrder(
        //         MarketDataTypes.UpdateOrderInputs({
        //             _market: address(this),
        //             _isLong: _inputs.isLong,
        //             _oraclePrice: _inputs.oraclePrice,
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

    function _buildDecreaseVars(
        MarketDataTypes.Cache memory _inputs,
        uint256 collateralIncreased,
        uint256 triggerPrice,
        bool isTP
    ) private view returns (MarketDataTypes.Cache memory _createVars) {
        _createVars.market = _inputs.market;
        _createVars.isLong = _inputs.isLong;
        _createVars.oraclePrice = _priceFacet().getPrice(_inputs.market, !_inputs.isLong);
        _createVars.isCreate = true;

        _createVars.fromOrder = _inputs.fromOrder;
        _createVars.account = _inputs.account;
        _createVars.sizeDelta = _inputs.sizeDelta;
        _createVars.collateral = 0; // painter0

        if ((isTP && _inputs.isKeepLevTP) || (false == isTP && _inputs.isKeepLevSL)) {
            _createVars.collateral = collateralIncreased;
            _createVars.isKeepLev = true;
        }
        _createVars.triggerAbove = isTP == _inputs.isLong;
        _createVars.price = triggerPrice;
        _createVars.refCode = _inputs.refCode;
    }

    function _increasePosition(MarketDataTypes.Cache memory _params, Position.Props memory _position)
        private
        returns (int256 collD)
    {
        (uint256 _longSize, uint256 _shortSize) = PositionHandler.getMarketSizes(_params.market);
        _feeFacet().updateCumulativeFundingRate(_params.market, _longSize, _shortSize); //1
        int256[] memory _fees = _feeFacet().getFees(abi.encode(_params, _position));
        int256 _totalfee = MarketHandler.totoalFees(_fees);

        if (_params.sizeDelta > 0) {
            MarketHandler.validPosition(abi.encode(_params, _position, _fees));
        } else {
            MarketHandler.validCollateralDelta(
                abi.encode(2, _position.collateral, _params.collateralDelta, _position.size, 0, _totalfee)
            );
        }
        int256 _fundingRate = _feeFacet().cumulativeFundingRates(_params.market, _params.isLong);
        collD = _params.collateralDelta.toInt256() - _totalfee;
        commitIncreasePosition(_params, collD, _fundingRate);
        (_params.account, _params.isLong);

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
}
