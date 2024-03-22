接口名称：合约工厂接口

### deploy

响应参数：

| 参数名 | 类型    | 描述                   |
| ------ | ------- | ---------------------- |
| asset  | address | 资产地址               |
| market | address | 市场地址               |
| name   | string  | 合约名称               |
| symbol | string  | 合约符号               |
| auth   | address | AccessManager 合约地址 |

### upgradeTo

升级

| 参数名            | 类型    | 描述           |
| ----------------- | ------- | -------------- |
| newImplementation | address | 新逻辑合约地址 |
