// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../order/OrderStruct.sol";

library MarketDataTypes {
    //***************************************************
    //        UpdateOrderInputs
    //***************************************************

    struct UpdateOrderInputs {
        address _market;
        bool _isLong;
        uint256 _oraclePrice;
        bool isOpen;
        bool isCreate;
        Order.Props _order;
        uint256[] inputs;
        // Sub-index meanings:
        // 0: Amount to pay (pay)
        // 1: Is transaction from market (isFromMarket)
        // 2: Slippage value (_slippage)
    }

    //***************************************************
    //        UpdatePositionInputs
    //***************************************************

    struct UpdatePositionInputs {
        address _market;
        bool _isLong;
        uint256 _oraclePrice;
        bool isOpen;
        //===========
        address _account;
        uint256 _sizeDelta;
        uint256 _price;
        uint256 _slippage;
        bool _isExec;
        uint8 liqState;
        uint64 _fromOrder;
        bytes32 _refCode;
        uint256 collateralDelta;
        uint8 execNum;
        //***************************************************
        //        Definition of values in inputs
        //***************************************************
        // Add-Position meanings:
        // 0: Take Profit (TP)
        // 1: Stop Loss (SL)
        // 2: Keep leverage when the Take Profit order is triggered (0 for false, 1 for true)
        // 3: Keep leverage when the Stop Loss order is triggered (0 for false, 1 for true)

        // Sub-position meanings:
        // 0: Is Keep Leverage (isKeepLev); 1 for true, 0 for false;
        uint256[] inputs;
        //***************************************************
    }

    uint256 constant ADD_POS_KEEP_LEVERAGE_ON_TAKE_PROFIT = 2;
    uint256 constant ADD_POS_KEEP_LEVERAGE_ON_STOP_LOSS = 3;

    function isFromMarket(
        UpdateOrderInputs memory _params
    ) internal pure returns (bool) {
        return _params.inputs.length >= 2 && _params.inputs[1] > 0;
    }
}
