
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;



contract DummyDiamondImplementation {


    struct Tuple21927 {
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

    struct Tuple2426236 {
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

    struct Tuple0408041 {
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

    struct Tuple2589231 {
        uint16 market;
        bool isLong;
        bool isIncrease;
        uint256 start;
        uint256 end;
        bool isOpen;
        uint256 oraclePrice;
        bytes32 storageKey;
    }

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

    struct Tuple803863 {
        uint32 maxDeviationBP;
        uint32 priceDuration;
        uint32 maxPriceUpdateDelay;
        uint32 priceDataInterval;
        uint32 sampleSpace;
    }

    struct Tuple8179501 {
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

    struct Tuple8634448 {
        uint16 market;
        address account;
        int256 collateralDelta;
        uint256 sizeDelta;
        int256 fundingRate;
        bool isLong;
    }

    struct Tuple8047955 {
        uint16 market;
        address account;
        int256 collateralDelta;
        uint256 sizeDelta;
        uint256 markPrice;
        int256 fundingRate;
        bool isLong;
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

    struct Tuple6871229 {
        address facetAddress;
        uint8 action;
        bytes4[] functionSelectors;
    }

    struct Tuple5605664 {
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

    struct Tuple557464 {
        bool success;
        bytes returnData;
    }

    struct Tuple3316247 {
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

    struct Tuple6022437 {
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

    struct Tuple09420 {
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

    struct Tuple6462124 {
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

    struct Tuple1236461 {
        address facetAddress;
        bytes4[] functionSelectors;
    }
    

   function authority() external view returns (address ) {}

   function setAuthority(address  newAuthority) external {}

   function implementation() external view returns (address ) {}

   function setDummyImplementation(address  _implementation) external {}

   function _addFee(uint16  market, bytes memory fee) external {}

   function _collectFees(bytes memory _data) external {}

   function _updateCumulativeFundingRate(uint16  market, uint256  longSize, uint256  shortSize) external {}

   function addSkipTime(uint16  market, uint256  start, uint256  end) external {}

   function cumulativeFundingRates(uint16  market, bool  isLong) external view returns (int256 ) {}

   function feeWithdraw(uint16  market, address  to, uint256  amount) external {}

   function getExecFee(uint16  market) external view returns (uint256 ) {}

   function getFeeAndRatesOfMarket(uint16  market) external view returns (uint256[] memory fees, int256[] memory fundingRates, int256[] memory _cumulativeFundingRates) {}

   function getFeesReceivable(Tuple21927 memory params, Tuple464693 memory position) external view returns (int256[] memory fees, int256  totalFee) {}

   function getFundingFee(uint16  market, uint256  size, int256  entryFundingRate, bool  isLong) external view returns (int256 ) {}

   function getGlobalOpenInterest(uint16  market) external view returns (uint256  _globalSize) {}

   function getNextFundingRate(address  market, uint256  longSize, uint256  shortSize) external {}

   function getOrderFees(Tuple2426236 memory data) external view returns (int256  fees) {}

   function initFeeFacet(uint16  market) external {}

   function setCalFundingRates(uint16  market, bool  isLong, int256  calFundingRate) external {}

   function setCalIntervals(uint16  market, uint256  interval) external {}

   function setFeeAndRates(uint16  market, uint8  feeType, uint256  feeAndRate) external {}

   function setFeeConfigs(uint16  market, uint8  configType, uint256  value) external {}

   function setFundFeeLoss(uint16  market, uint256  loss) external {}

   function setFundingIntervals(uint16  market, uint256  interval) external {}

   function setFundingRates(uint16  market, bool  isLong, int256  fundingRate, int256  cumulativeFundingRate) external {}

   function setLastCalTimes(uint16  market, uint256  lastCalTime) external {}

   function marketMakerForConfig(bool  isSuspended, bool  allowOpen, bool  allowClose, bool  validDecrease, uint16  minSlippage, uint16  maxSlippage, uint16  minLeverage, uint16  maxLeverage, uint16  minPayment, uint16  minCollateral, uint16  decreaseNumLimit, uint32  maxTradeAmount) external pure returns (Tuple5605664 memory) {}

   function marketMakerForFee(uint256  maxFRatePerDay, uint256  fRateFactor, uint256  mintFRate, uint256  minFundingInterval, uint256  fundingFeeLossOffLimit) external pure returns (bytes memory) {}

   function marketMakerForOracle(address  pricefeed, uint256  maxCumulativeDeltaDiffs) external pure returns (bytes memory) {}

   function _addGValid(uint16  market, uint256  maxMarketSizeLimit) external {}

   function _addMarket(bytes memory data) external returns (uint16  market) {}

   function _addOracle(uint16  market, bytes memory oracle) external {}

   function addMarket(string memory name, address  _vault, uint256  maxMarketSizeLimit, Tuple0408041 memory config, bytes memory oracle, bytes memory fee) external returns (uint16  market) {}

   function availableLiquidity(address  market, address  account, bool  isLong) external view returns (uint256 ) {}

   function containsMarket(uint16  marketId) external view returns (bool ) {}

   function getExecutableOrdersByPrice(Tuple2589231 memory cache) external view returns (Tuple564566[] memory _orders) {}

   function getGlobalPnl(address  _vault) external view returns (int256 ) {}

   function getMarket(uint16  market) external view returns (bytes memory result) {}

   function getMarkets() external view returns (bytes memory result) {}

   function getUSDDecimals() external pure returns (uint8 ) {}

   function markeConfig(uint16  market) external view returns (Tuple826895 memory _config) {}

   function removeMarket(uint16  marketId) external {}

   function setMarketConf(uint16  market, Tuple9273272 memory data) external {}

   function aggregateCall(bytes[] memory calls) external returns (uint256  blockNumber, bytes[] memory returnData) {}

   function aggregateStaticCall(bytes[] memory calls) external view returns (uint256  blockNumber, bytes[] memory returnData) {}

   function blockAndAggregate(bytes[] memory calls) external returns (uint256  blockNumber, bytes32  blockHash, Tuple557464[] memory returnData) {}

   function getBlockHash(uint256  blockNumber) external view returns (bytes32  blockHash) {}

   function getBlockNumber() external view returns (uint256  blockNumber) {}

   function getCurrentBlockCoinbase() external view returns (address  coinbase) {}

   function getCurrentBlockGasLimit() external view returns (uint256  gaslimit) {}

   function getCurrentBlockTimestamp() external view returns (uint256  timestamp) {}

   function getEthBalance(address  addr) external view returns (uint256  balance) {}

   function getLastBlockHash() external view returns (bytes32  blockHash) {}

   function tryAggregate(bool  requireSuccess, bytes[] memory calls) external returns (Tuple557464[] memory returnData) {}

   function tryBlockAndAggregate(bool  requireSuccess, bytes[] memory calls) external returns (uint256  blockNumber, bytes32  blockHash, Tuple557464[] memory returnData) {}

   function getChainPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function getFastPrice(uint16  market, uint256  _referencePrice, bool  _maximise) external view returns (uint256 ) {}

   function getPrice(uint16  market, bool  _maximise) external view returns (uint256 ) {}

   function initDefaultOracleConfig() external {}

   function priceFeed(uint16  market) external view returns (address ) {}

   function setMaxCumulativeDeltaDiffs(uint16[] memory _market, uint256[] memory _maxCumulativeDeltaDiffs) external {}

   function setOracleConfig(Tuple803863 memory _config) external {}

   function setPrices(uint16[] memory _markets, uint256[] memory _prices) external {}

   function setUSDT(address  _feed) external {}

   function usdtFeed() external view returns (address ) {}

   function _addOrders(Tuple8179501[] memory _inputs) external returns (Tuple564566[] memory _orders) {}

   function cancelOrder(address  account, uint16  market, bool  isIncrease, uint256  orderID, bool  isLong) external returns (Tuple564566[] memory _orders) {}

   function updateOrder(Tuple910965 memory _inputs) external payable {}

   function execAddOrder(Tuple680644 memory order, Tuple5849784 memory _params) external {}

   function getAccountSizeOfMarkets(uint16  market, address  account) external view returns (uint256  sizesL, uint256  sizesS) {}

   function getGlobalSize(uint16  market) external view returns (uint256  sizesLong, uint256  sizesShort) {}

   function getMarketsOfMarket(uint16  market) external view returns (uint256[] memory) {}

   function _decreasePosition(Tuple8634448 memory inputs) external returns (Tuple3316247 memory result) {}

   function _increasePosition(Tuple8047955 memory _data) external returns (Tuple3316247 memory result) {}

   function _liquidatePosition(uint16  market, address  account, uint256  oraclePrice, bool  isLong) external returns (Tuple3316247 memory result) {}

   function containsPositionOfUser(uint16  market, address  account) external view returns (bool ) {}

   function getAccountSize(uint16  market, address  account) external view returns (uint256 , uint256 ) {}

   function getGlobalPosition(uint16  market, bool  isLong) external view returns (Tuple6022437 memory) {}

   function getMarketSizes(uint16  market) external view returns (uint256 , uint256 ) {}

   function getPNLOfMarket(uint16  market) external view returns (int256  pnl) {}

   function getPNLOfUser(uint16  market, address  account, uint256  sizeDelta, uint256  markPrice, bool  isLong) external view returns (int256 ) {}

   function getPosition(uint16  market, address  account, uint256  markPrice, bool  isLong) external view returns (Tuple6022437 memory) {}

   function getPositionCount(uint16  market, bool  isLong) external view returns (uint256 ) {}

   function getPositionKeys(uint16  market, uint256  start, uint256  end, bool  isLong) external view returns (address[] memory) {}

   function getPositions(uint16  market, address  account) external view returns (Tuple09420 memory posLong, Tuple6462124 memory posShort) {}

   function isLiquidate(address  _account, uint16  _market, bool  _isLong, uint256  _price) external view returns (uint8  _state) {}

   function execSubOrder(Tuple680644 memory order, Tuple5849784 memory _params) external {}

   function liquidate(uint16  market, address  accounts, bool  _isLong) external {}

   function _updatePositionCallback(Tuple4013238 memory _event) external {}

   function getCodeOwners(bytes32  _code) external view returns (address ) {}

   function govSetCodeOwner(bytes32  _code, address  _newAccount) external {}

   function registerCode(bytes32  _code) external {}

   function setCodeOwner(bytes32  _code, address  _newAccount) external {}

   function setReferrerDiscountShare(address  _account, uint256  _discountShare) external {}

   function setReferrerTier(address  _referrer, uint256  _tierId) external {}

   function setTier(uint256  _tierId, uint256  _totalRebate, uint256  _discountShare) external {}

   function setTraderReferralCodeByGov(address  _account, bytes32  _code) external {}

   function setTraderReferralCodeByUser(bytes32  _code) external {}

   function diamondCut(Tuple6871229[] memory _diamondCut, address  _init, bytes memory _calldata) external {}

   function owner() external view returns (address  owner_) {}

   function transferOwnership(address  _newOwner) external {}

   function facetAddress(bytes4  _functionSelector) external view returns (address  facetAddress_) {}

   function facetAddresses() external view returns (address[] memory facetAddresses_) {}

   function facetFunctionSelectors(address  _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}

   function facets() external view returns (Tuple1236461[] memory facets_) {}

   function supportsInterface(bytes4  _interfaceId) external view returns (bool ) {}
}
