// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

library MarketHandler { /* is IOrderBook, Ac */
    bytes32 constant STORAGE_POSITION = keccak256("blex.market.storage");

    using EnumerableSet for EnumerableSet.UintSet;

    enum CancelReason {
        Padding, //0
        Liquidation, //1
        PositionClosed, //2
        Executed, //3
        TpAndSlExecuted, //4
        Canceled, //5
        SysCancel, //6invalid order
        LeverageLiquidation //7

    }

    struct Props {
        bool isSuspended;
        bool allowOpen;
        bool allowClose;
        bool validDecrease;
        uint16 minSlippage;
        uint16 maxSlippage;
        uint16 minLeverage;
        uint16 maxLeverage;
        uint16 minPayment;
        uint16 minCollateral;
        uint16 decreaseNumLimit; //default: 10
        uint32 maxTradeAmount;
    }

    struct StorageStruct {
        address oracle;
        mapping(uint16 => Props) config;
        mapping(uint16 => string) name;
        mapping(uint16 => address) vault;
        mapping(uint16 => address) token;
        mapping(uint16 => uint256) balance;
        mapping(address vault => EnumerableSet.UintSet) marketIds;
    }

    function vault(uint16 market) internal view returns (address) {
        return MarketHandler.Storage().vault[market];
    }

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function collateralToken(uint16 market) internal view returns (address) {
        return Storage().token[market];
    }

    function validPosition(bytes memory data) internal view {
        //     uint16 market;
        //     bool isIncrease;
        //     if (isIncrease) {
        //         validPay(market, 0);
        //     }
        //     uint256 _sizeDelta = 0;
        //     if (_sizeDelta > 0) {} else {
        //         validCollateralDelta(data);
        //     }
        //     // MarketDataTypes.UpdatePositionInputs memory params,
        //     // PositionProps memory position,
        //     // int256[] memory fees
    }

    // function validIncreaseOrder(bytes memory data) internal view {
    //     uint16 market;
    //     validPay(market, 0);
    //     // MarketDataTypes.UpdateOrderInputs memory vars,
    //     // int256 fees
    // }

    // function validDecreaseOrder(bytes memory data) internal view {
    //     // uint16 market,
    //     // uint256 collateral,
    //     // uint256 collateralDelta,
    //     // uint256 size,
    //     // uint256 sizeDelta,
    //     // int256 fees,
    //     // uint256 decrOrderCount
    // }

    function validLev(uint16 market, uint256 newSize, uint256 newCollateral) internal view {}
    // function validTPSL(uint16 market, uint256 triggerPrice, uint256 tpPrice, uint256 slPrice, bool isLong)
    //     internal
    //     pure
    // {}

    function getDecreaseOrderValidation(uint16 market, uint256 decrOrderCount) internal view returns (bool isValid) {}

    function validateLiquidation(uint16 market, int256 fees, int256 liquidateFee, bool raise)
        internal
        view
        returns (uint8)
    {}
    // //================================================================================================
    // // internal
    // //================================================================================================
    // function validSize(uint16 market, uint256 size, uint256 sizeDelta, bool isIncrease) internal pure {}
    // function validMarkPrice(uint16 market, bool isLong, uint256 price, bool isIncrease, bool isExec, uint256 markPrice)
    //     internal
    //     pure
    // {}

    // function validSlippagePrice(bytes memory data) internal view {
    //     // MarketDataTypes.UpdatePositionInputs memory inputs // uint256 price, // （usdt） // bool isLong, // uint256 slippage, // bool isIncrease, // bool isExec, // uint256 markPrice
    // }
    function validCollateralDelta(bytes memory data) internal view {
        //     // uint16 market,
        //     // uint256 busType, // 1:increase 2. increase coll 3. decrease 4. decrease coll
        //     // uint256 collateral,
        //     // uint256 collateralDelta,
        //     // uint256 size,
        //     // uint256 sizeDelta,
        //     // int256 fees
    }
    function validPay(uint16 market, uint256 pay) internal view {
        //todo
    }
}
