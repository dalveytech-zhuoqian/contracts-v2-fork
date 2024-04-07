
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;



contract DummyDiamondImplementation {


    struct Tuple9273272 {
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
        uint16 decreaseNumLimit;
        uint32 maxTradeAmount;
    }

    struct Tuple910965 {
        uint8 busiType;
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
        uint8 liqState;
        uint64 fromOrder;
        bytes32 refCode;
        uint8 execNum;
        bool isKeepLev;
        bool isKeepLevTP;
        bool isKeepLevSL;
        bool triggerAbove;
        uint128 gas;
    }

    struct Tuple680644 {
        bytes32 refCode;
        uint128 collateral;
        uint128 size;
        uint256 price;
        uint256 tp;
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
        address account;
        uint96 extra1;
        uint256 sl;
        bool isIncrease;
        bool isLong;
        uint16 market;
        uint96 extra2;
        uint128 gas;
        uint8 version;
    }

    struct Tuple5849784 {
        uint8 busiType;
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
        uint8 liqState;
        uint64 fromOrder;
        bytes32 refCode;
        uint8 execNum;
        bool isKeepLev;
        bool isKeepLevTP;
        bool isKeepLevSL;
        bool triggerAbove;
        uint128 gas;
    }

    struct Tuple4013238 {
        Tuple0521689 inputs;
        Tuple464693 position;
        int256[] fees;
        address collateralToken;
        address indexToken;
        int256 collateralDeltaAfter;
    }

    struct Tuple0521689 {
        uint8 busiType;
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
        uint8 liqState;
        uint64 fromOrder;
        bytes32 refCode;
        uint8 execNum;
        bool isKeepLev;
        bool isKeepLevTP;
        bool isKeepLevSL;
        bool triggerAbove;
        uint128 gas;
    }

    struct Tuple464693 {
        uint256 size;
        uint256 collateral;
        int256 entryFundingRate;
        int256 realisedPnl;
        uint256 averagePrice;
        bool isLong;
        uint32 lastTime;
        uint16 market;
        uint72 extra0;
    }

    struct Tuple6871229 {
        address facetAddress;
        uint8 action;
        bytes4[] functionSelectors;
    }

    struct Tuple826895 {
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
        uint16 decreaseNumLimit;
        uint32 maxTradeAmount;
    }

    struct Tuple564566 {
        bytes32 refCode;
        uint128 collateral;
        uint128 size;
        uint256 price;
        uint256 tp;
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
        address account;
        uint96 extra1;
        uint256 sl;
        bool isIncrease;
        bool isLong;
        uint16 market;
        uint96 extra2;
        uint128 gas;
        uint8 version;
    }

    struct Tuple1236461 {
        address facetAddress;
        bytes4[] functionSelectors;
    }
    

   function addMarket(bytes memory data) external {}

   function availableLiquidity(address  market, address  account, bool  isLong) external view returns (uint256 ) {}

   function containsMarket(uint16  marketId) external view returns (bool ) {}

   function getGlobalPnl(address  vault) external view returns (int256 ) {}

   function getMarket(uint16  market) external view returns (bytes memory result) {}

   function getMarkets() external view returns (bytes memory result) {}

   function getUSDDecimals() external pure returns (uint8 ) {}

   function isLiquidate(uint16  market, address  account, bool  isLong) external view {}

   function markeConfig(uint16  market) external view returns (Tuple826895 memory _config) {}

   function parseVaultAsset(uint256  amount, uint8  originDigits) external pure returns (uint256 ) {}

   function parseVaultAssetSigned(int256  amount, uint8  collateralTokenDigits) external pure returns (int256 ) {}

   function removeMarket(uint16  marketId) external {}

   function setMarketConf(uint16  market, Tuple9273272 memory data) external {}

   function transferIn(address  tokenAddress, address  _from, address  _to, uint256  _tokenAmount) external {}

   function authority() external view returns (address ) {}

   function setAuthority(address  newAuthority) external {}

   function implementation() external view returns (address ) {}

   function setDummyImplementation(address  _implementation) external {}

   function getChainPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function getFastPrice(uint16  market, uint256  _referencePrice, bool  _maximise) external view returns (uint256 ) {}

   function getPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function initDefaultOracleConfig() external {}

   function setMaxCumulativeDeltaDiffs(uint16[] memory _market, uint256[] memory _maxCumulativeDeltaDiffs) external {}

   function setOracleConfig(bytes memory _data) external {}

   function setPrices(uint16[] memory _markets, uint256[] memory _prices) external {}

   function setUSDT(address  _feed) external {}

   function cancelOrder(address  account, uint16  market, bool  isIncrease, uint256  orderID, bool  isLong) external returns (Tuple564566[] memory _orders) {}

   function updateOrder(Tuple910965 memory _inputs) external payable {}

   function execAddOrder(Tuple680644 memory order, Tuple5849784 memory _params) external {}

   function getAccountSizeOfMarkets(uint16  market, address  account) external view returns (uint256  sizesL, uint256  sizesS) {}

   function getGlobalSize(uint16  market) external view returns (uint256  sizesLong, uint256  sizesShort) {}

   function getMarketsOfMarket(uint16  market) external view returns (uint256[] memory) {}

   function execSubOrder(Tuple680644 memory order, Tuple5849784 memory _params) external {}

   function liquidate(uint16  market, address  accounts, bool  _isLong) external {}

   function getCodeOwners(bytes32  _code) external view returns (address ) {}

   function govSetCodeOwner(bytes32  _code, address  _newAccount) external {}

   function registerCode(bytes32  _code) external {}

   function setCodeOwner(bytes32  _code, address  _newAccount) external {}

   function setReferrerDiscountShare(address  _account, uint256  _discountShare) external {}

   function setReferrerTier(address  _referrer, uint256  _tierId) external {}

   function setTier(uint256  _tierId, uint256  _totalRebate, uint256  _discountShare) external {}

   function setTraderReferralCodeByGov(address  _account, bytes32  _code) external {}

   function setTraderReferralCodeByUser(bytes32  _code) external {}

   function updatePositionCallback(Tuple4013238 memory _event) external {}

   function diamondCut(Tuple6871229[] memory _diamondCut, address  _init, bytes memory _calldata) external {}

   function owner() external view returns (address  owner_) {}

   function transferOwnership(address  _newOwner) external {}

   function facetAddress(bytes4  _functionSelector) external view returns (address  facetAddress_) {}

   function facetAddresses() external view returns (address[] memory facetAddresses_) {}

   function facetFunctionSelectors(address  _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}

   function facets() external view returns (Tuple1236461[] memory facets_) {}

   function supportsInterface(bytes4  _interfaceId) external view returns (bool ) {}
}
