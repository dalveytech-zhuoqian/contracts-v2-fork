以下是合同中所有外部函数的Markdown接口文档：

### `initialize`

#### 描述

初始化函数，用于设置初始权限。

#### 参数

- **address** `initialAuthority`: 初始权限的地址

#### 返回值

- 无

#### 示例

```solidity
// 示例使用initialize函数
```

---

### `getVaultRewards`

#### 描述

获取Vault奖励集合。

#### 参数

- 无

#### 返回值

- **address[] memory**: 包含Vault奖励地址的数组

#### 示例

```solidity
// 示例使用getVaultRewards函数
```

---

### `addMarketReader`

#### 描述

向Market Reader集合中添加新的Market Reader。

#### 参数

- **address** `market`: 市场地址

#### 返回值

- 无

#### 示例

```solidity
// 示例使用addMarketReader函数
```

---

### `increasePosition`

#### 描述

增加市场仓位。

#### 参数

- **MarketDataTypes.UpdatePositionInputs memory** `_vars`: 包含更新仓位信息的结构体

#### 返回值

- 无

#### 示例

```solidity
// 示例使用increasePosition函数
```

---

### `decreasePosition`

#### 描述

减少市场仓位。

#### 参数

- **MarketDataTypes.UpdatePositionInputs memory** `_vars`: 包含更新仓位信息的结构体

#### 返回值

- 无

#### 示例

```solidity
// 示例使用decreasePosition函数
```

---

### `updateOrder`

#### 描述

更新订单信息。

#### 参数

- **MarketDataTypes.UpdateOrderInputs memory** `_vars`: 包含更新订单信息的结构体

#### 返回值

- 无

#### 示例

```solidity
// 示例使用updateOrder函数
```

---

### `cancelOrderList`

#### 描述

取消订单列表。

#### 参数

- **address[] memory** `_markets`: 市场地址数组
- **bool[] memory** `_isIncreaseList`: 是否增加的标志数组
- **uint256[] memory** `_orderIDList`: 订单ID数组
- **bool[] memory** `_isLongList`: 是否为多头的标志数组

#### 返回值

- 无

#### 示例

```solidity
// 示例使用cancelOrderList函数
```

---

### `getNextFundingRate`

#### 描述

获取下一个资金费率。

#### 参数

- **address** `market`: 市场地址
- **uint256** `longSize`: 多头仓位大小
- **uint256** `shortSize`: 空头仓位大小

#### 返回值

- 无

#### 示例

```solidity
// 示例使用getNextFundingRate函数
```

---

### `getMarkets`

#### 描述

获取所有市场的信息。

#### 参数

- 无

#### 返回值

- **IMarketFactory.Outs[] memory**: 包含所有市场信息的数组

#### 示例

```solidity
// 示例使用getMarkets函数
```

---

### `isLiquidate`

#### 描述

检查是否应进行清算。

#### 参数

- **address** `market`: 市场地址
- **address** `account`: 用户地址
- **bool** `isLong`: 是否为多头仓位

#### 返回值

- **uint256**: 清算状态

#### 示例

```solidity
// 示例使用isLiquidate函数
```

---

### `getFundingRate`

#### 描述

获取资金费率。

#### 参数

- **address** `market`: 市场地址
- **bool** `isLong`: 是否为多头仓位

#### 返回值

- **int256, int256**: 资金费率

#### 示例

```solidity
// 示例使用getFundingRate函数
```

---

### `availableLiquidity`

#### 描述

获取可用流动性。

#### 参数

- **address** `market`: 市场地址
- **address** `account`: 用户地址
- **bool** `isLong`: 是否为多头仓位

#### 返回值

- **uint256**: 可用流动性数量

#### 示例

```solidity
// 示例使用availableLiquidity函数
```

---

### `getMarket`

#### 描述

获取指定市场的信息。

#### 参数

- **address** `market`: 市场地址

#### 返回值

- **IMarketReader.ValidOuts memory, IMarketReader.MarketOuts memory, IMarketReader.FeeOuts memory**: 市场信息的结构体

#### 示例

```solidity
// 示例使用getMarket函数
```

---

### `getPositions`

#### 描述

获取指定用户在指定市场的仓位信息。

#### 参数

- **address** `account`: 用户地址
- **address** `market`: 市场地址

#### 返回值

- **Position.Props[] memory**: 包含用户仓位信息的数组

#### 示例

```solidity
// 示例使用getPositions函数
```

---

### `getFundingFee`

#### 描述

获取资金费用。

#### 参数

- **address** `account`: 用户地址
- **address** `market`: 市场地址
- **bool** `isLong`: 是否为多头仓位

#### 返回值

- **int256**: 资金费用

#### 示例

```solidity
// 示例使用getFundingFee函数
```

---

以上是合同中每个外部函数的简要文档。如果您需要更详细的信息或有其他问题，请随时询问！