根据合约中的注释和函数可见性，生成该合约的 public 和 external 函数接口文档如下：

### Public 函数接口

6. **convertToShares**

   - 描述：将资产数量转换为份额数量
   - 函数签名：`function convertToShares(uint256 assets) public view virtual returns (uint256)`

7. **convertToAssets**

   - 描述：将份额数量转换为资产数量
   - 函数签名：`function convertToAssets(uint256 shares) public view virtual returns (uint256)`

8. **previewDeposit**

   - 描述：预览存款操作后的份额数量
   - 函数签名：`function previewDeposit(uint256 assets) public view virtual returns (uint256)`

9. **previewMint**

   - 描述：预览铸币操作后的资产数量
   - 函数签名：`function previewMint(uint256 shares) public view virtual returns (uint256)`

10. **previewWithdraw**

    - 描述：预览提款操作后的份额数量
    - 函数签名：`function previewWithdraw(uint256 assets) public view virtual returns (uint256)`

11. **previewRedeem**
    - 描述：预览赎回操作后的资产数量
    - 函数签名：`function previewRedeem(uint256 shares) public view virtual returns (uint256)`
