// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

enum MarketBusinessType {
    None,
    Increase,
    IncreaseCollateral,
    Decrease,
    DecreaseCollateral
}

enum LiquidationState {
    None,
    Collateral,
    Leverage
}

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

enum FeeType {
    OpenFee, // 0
    CloseFee, // 1
    FundFee, // 2
    ExecFee, // 3
    LiqFee, // 4
    BuyLpFee, // 5
    SellLpFee, // 6
    ExtraFee0,
    ExtraFee1,
    ExtraFee2,
    ExtraFee3,
    ExtraFee4,
    Counter
}

struct GValid {
    uint16 market;
    uint256 sizeDelta;
    bool isLong;
    uint256 globalLongSizes;
    uint256 globalShortSizes;
    uint256 userLongSizes;
    uint256 userShortSizes;
    uint256 marketLongSizes;
    uint256 marketShortSizes;
    uint256 aum;
}

struct OrderProps {
    //====0
    bytes32 refCode;
    //====1
    uint128 collateral;
    uint128 size;
    //====2
    uint256 price;
    uint256 tp;
    //====3
    bool triggerAbove;
    bool isFromMarket;
    bool isKeepLev;
    bool isKeepLevTP;
    bool isKeepLevSL;
    uint64 orderID;
    uint64 pairId;
    uint64 fromId;
    uint32 updatedAtBlock;
    uint8 extra0;
    //====4
    address account; //224
    uint96 extra1;
    //====5
    uint256 sl;
    bool isIncrease;
    bool isLong;
    uint16 market;
    uint96 extra2; //todo
    uint128 gas;
    uint8 version;
}

struct PositionProps {
    // 1
    uint256 size;
    uint256 collateral;
    // 2
    int256 entryFundingRate;
    // 3
    int256 realisedPnl;
    // 4
    uint256 averagePrice;
    bool isLong;
    uint32 lastTime;
    uint16 market;
    uint72 extra0;
}

struct MarketCache {
    MarketBusinessType busiType;
    uint256 oraclePrice;
    uint256 pay;
    uint256 slippage;
    uint16 market;
    bool isLong;
    bool isOpen;
    bool isCreate;
    bool isFromMarket;
    uint256 sizeDelta;
    uint256 price;
    uint256 collateralDelta;
    uint256 collateral;
    uint256 tp;
    uint256 sl;
    uint64 orderId;
    address account;
    bool isExec;
    LiquidationState liqState;
    uint64 fromOrder;
    bytes32 refCode;
    uint8 execNum;
    bool isKeepLev;
    bool isKeepLevTP;
    bool isKeepLevSL;
    bool triggerAbove;
    uint128 gas;
}
