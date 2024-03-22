接口文档如下：

### **VaultReward 合约接口文档**

#### **buy**

购买 Vault 的份额

- **函数签名:**
  ```solidity
  function buy(address to, uint256 amount, uint256 minSharesOut) public override nonReentrant returns (uint256 sharesOut)
  ```
- **参数:**
  - `to`: 购买份额的接收地址
  - `amount`: 使用的 ERC20 代币数量
  - `minSharesOut`: 预期最小份额数量
- **返回值:**
  - `sharesOut`: 实际购买的份额数量

#### **sell**

出售 Vault 的份额

- **函数签名:**
  ```solidity
  function sell(address to, uint256 shares, uint256 minAssetsOut) public override nonReentrant returns (uint256 assetOut)
  ```
- **参数:**
  - `to`: 出售份额的接收地址
  - `shares`: 出售的份额数量
  - `minAssetsOut`: 预期最小资产数量
- **返回值:**
  - `assetOut`: 实际获得的资产数量

#### **claimLPReward**

领取 LP 的奖励

- **函数签名:**
  ```solidity
  function claimLPReward() public override nonReentrant
  ```

#### **setAPR**

设置年化利率

- **函数签名:**
  ```solidity
  function setAPR(uint256 _apr) external restricted
  ```
- **参数:**
  - `_apr`: 年化利率
