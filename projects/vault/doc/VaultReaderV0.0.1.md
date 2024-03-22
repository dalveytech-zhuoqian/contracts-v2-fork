# 接口文档

## `VaultReader` 合约

### 版本信息

- 版本号: 0.0.1

### 函数

#### `constructor(address _vault, address _vaultReward)`

- 描述: 构造函数，初始化 VaultReader 合约
- 参数:
  - `_vault`: Vault 合约地址
  - `_vaultReward`: VaultReward 合约地址

#### `info(address _account) external view returns (Cache memory c)`

- 描述: 获取指定账户的相关信息
- 参数:
  - `_account`: 目标账户地址
- 返回值: Cache 结构体

### 结构体

#### `Cache`

- 描述: 存储获取到的信息
- 属性:
  - `rewardToken`: 奖励代币地址
  - `priceDecimals`: 价格小数位数
  - `stakedAmounts`: 用户在 Vault 中的质押数量
  - `price`: LP 价格
  - `sellFee`: 出售 LP 手续费
  - `buyFee`: 购买 LP 手续费
  - `pendingReward`: 待领取奖励数量
  - `apr`: 年化收益率
  - `priceDecimal`: 价格小数位数
  - `usdBalance`: USD 余额
  - `lpReward`: 已经领取的奖励

### 接口依赖

- 依赖接口:
  - `IVault`: Vault 合约接口
  - `IVaultReward`: VaultReward 合约接口

---
