# feerouter

### market 内部调用

function updateCumulativeFundingRate(
address market,
uint256 longSize,
uint256 shortSize
) external

function payoutFees(
address account,
address token,
int256[] memory fees,
uint256 feesTotal
) external

function getOrderFees(
MarketDataTypes.UpdateOrderInputs memory params
) external view returns (int256 fees)

### market 外(前端、后端、管理员、 vault 、周边合约)调用

function setFeeAndRates( address market,
uint256[] memory rates
) external

function withdraw(
address token,
address to,
uint256 amount
) external

### 通用

function collectFees(
address account,
address token,
int256[] memory fees
) external

function collectFees(
address account,
address token,
int256[] memory fees,
uint256 fundfeeLoss
) external

function getExecFee(address market) external view returns (uint256)

function getFundingRate(
address market,
bool isLong
) external view returns (int256)

function cumulativeFundingRates(
address market,
bool isLong
) external view returns (int256)

function getFees(
MarketDataTypes.UpdatePositionInputs memory params,
Position.Props memory position
) external view returns (int256[] memory fees)

# fundfee

### 内部

function getCalFundingRates(
address market
) public view returns (int256, int256)

### 外部

function getNextFundingRate(
address market,
uint256 longSize,
uint256 shortSize
) public

### 通用

function getFundingFee(
address market,
uint256 size,
int256 entryFundingRate,
bool isLong
) external view returns (int256)

function getGlobalOpenInterest() public view returns (uint256 \_globalSize)

# feevault

### 内部调用

废弃

function withdraw(
address token,
address to,
uint256 amount
) external

废弃

function updateGlobalFundingRate(
address market,
int256 longRate,
int256 shortRate,
int256 nextLongRate,
int256 nextShortRate,
uint256 timestamp
) external onlyController
