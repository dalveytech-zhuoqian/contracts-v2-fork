
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

    struct Tuple9848150 {
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

    struct Tuple8473922 {
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

    struct Tuple2000403 {
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

    struct Tuple6442409 {
        Tuple894709 inputs;
        Tuple464693 position;
        int256[] fees;
        address collateralToken;
        address indexToken;
        int256 collateralDeltaAfter;
    }

    struct Tuple894709 {
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

    struct Tuple1236461 {
        address facetAddress;
        bytes4[] functionSelectors;
    }
    

   function addMarket(bytes memory data) external {}

   function availableLiquidity(address  market, address  account, bool  isLong) external view returns (uint256 ) {}

   function containsMarket(uint16  marketId) external view returns (bool ) {}

   function formatCollateral(uint256  amount, uint8  collateralTokenDigits) external pure returns (uint256 ) {}

   function getGlobalPnl(address  vault) external view returns (int256 ) {}

   function getMarket(uint16  market) external view returns (bytes memory result) {}

   function getMarkets() external view returns (bytes memory result) {}

   function getUSDDecimals() external pure returns (uint8 ) {}

   function isLiquidate(uint16  market, address  account, bool  isLong) external view {}

   function markeConfig(uint16  market) external view returns (Tuple826895 memory _config) {}

   function parseVaultAsset(uint256  amount, uint8  originDigits) external pure returns (uint256 ) {}

   function parseVaultAssetSigned(int256  amount, uint8  collateralTokenDigits) external pure returns (int256 ) {}

   function removeMarket(uint16  marketId) external {}

   function setConf(uint16  market, Tuple9273272 memory data) external {}

   function transferIn(address  tokenAddress, address  _from, address  _to, uint256  _tokenAmount) external {}

   function transferOut(address  tokenAddress, address  _to, uint256  _tokenAmount) external {}

   function usdDecimals() external view returns (uint8 ) {}

   function authority() external view returns (address ) {}

   function setAuthority(address  newAuthority) external {}

   function implementation() external view returns (address ) {}

   function setDummyImplementation(address  _implementation) external {}

   function getChainPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function getFastPrice(uint16  market, uint256  _referencePrice, bool  _maximise) external view returns (uint256 ) {}

   function getPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function initDefaultOracleConfig() external {}

   function setConfig(bytes memory _data) external {}

   function setMaxCumulativeDeltaDiffs(uint16[] memory _market, uint256[] memory _maxCumulativeDeltaDiffs) external {}

   function setPrices(uint16[] memory _markets, uint256[] memory _prices) external {}

   function setUSDT(address  _feed) external {}

   function cancelOrder(address  markets, bool  isIncrease, uint256  orderID, bool  isLong) external {}

   function sysCancelOrder(address  user, address  markets, bool  isIncrease, uint256  orderID, bool  isLong) external {}

   function updateOrder(bytes memory data) external payable {}

   function _increasePositionWithOrders(Tuple9848150 memory _inputs) external {}

   function execAddOrderKey(Tuple8473922 memory exeOrder, Tuple2000403 memory _params) external {}

   function getAccountSizeOfMarkets(uint16  market, address  account) external view returns (uint256  sizesL, uint256  sizesS) {}

   function getGlobalSize(uint16  market) external view returns (uint256  sizesLong, uint256  sizesShort) {}

   function execSubOrderKey(Tuple680644 memory order, Tuple2000403 memory _params) external {}

   function liquidate(uint16  market, address  accounts, bool  _isLong) external {}

   function getCodeOwners(bytes32  _code) external view returns (address ) {}

   function govSetCodeOwner(bytes32  _code, address  _newAccount) external {}

   function registerCode(bytes32  _code) external {}

   function setCodeOwner(bytes32  _code, address  _newAccount) external {}

   function setReferrerDiscountShare(address  _account, uint256  _discountShare) external {}

   function setReferrerTier(address  _referrer, uint256  _tierId) external {}

   function setTier(uint256  _tierId, uint256  _totalRebate, uint256  _discountShare) external {}

   function setTraderReferralCode(address  _account, bytes32  _code) external {}

   function setTraderReferralCodeByUser(bytes32  _code) external {}

   function updatePositionCallback(Tuple6442409 memory _event) external {}

   function diamondCut(Tuple6871229[] memory _diamondCut, address  _init, bytes memory _calldata) external {}

   function owner() external view returns (address  owner_) {}

   function transferOwnership(address  _newOwner) external {}

   function facetAddress(bytes4  _functionSelector) external view returns (address  facetAddress_) {}

   function facetAddresses() external view returns (address[] memory facetAddresses_) {}

   function facetFunctionSelectors(address  _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}

   function facets() external view returns (Tuple1236461[] memory facets_) {}

   function supportsInterface(bytes4  _interfaceId) external view returns (bool ) {}
}
