# Boilerplate for ethereum solidity smart contract

文件夹目录

- artifacts: hardhat 编译后的 abi
- cache: hardhat 缓存
- cache_forge: foundry 缓存
- deploy: deploy scripts for hardhat-deploy
- deployments: 部署之后生成的地址和 abi, 以及用于验证合约的 metadata
- etherscan_requests: 以太坊浏览器的 debug 文件
- lib/forge-std: foundry 标准库
- node_modules: 依赖包
- out_forge: foundry 输出的编译 abi(单元测试使用)
- scripts: 脚本
- src: 合约源代码
- test: 功能测试
- test_forge: 单元测试脚本
- typechains: typechain 编译生成的 ts 接口兼容文件
- utils: 框架自带的与部署相关的文件(不要动)

## INSTALL

```bash
git submodule update --init --recursive && yarn
```

## TEST

There are 3 flavors of tests: hardhat, dapptools and forge

### hardhat 功能测试

- One using hardhat that can leverage hardhat-deploy to reuse deployment procedures and named accounts:

```bash
yarn test
```

### forge 单元测试

```bash
forge build && forge test
```

This require the installation of forge (see [foundry](https://github.com/gakonst/foundry))

## SCRIPTS

Here is the list of npm scripts you can execute:

Some of them relies on [./\_scripts.js](./_scripts.js) to allow parameterizing it via command line argument (have a look inside if you need modifications)
<br/><br/>

### `yarn prepare`

As a standard lifecycle npm script, it is executed automatically upon install. It generate config file and typechain to get you started with type safe contract interactions
<br/><br/>

### `yarn format` and `yarn format:fix`

These will format check your code. the `:fix` version will modifiy the files to match the requirement specified in `.prettierrc.`
<br/><br/>

### `yarn compile`

These will compile your contracts
<br/><br/>

### `yarn void:deploy`

This will deploy your contracts on the in-memory hardhat network and exit, leaving no trace. quick way to ensure deployments work as intended without consequences
<br/><br/>

### `yarn test [mocha args...]`

These will execute your tests using mocha. you can pass extra arguments to mocha
<br/><br/>

### `yarn coverage`

These will produce a coverage report in the `coverage/` folder
<br/><br/>

### `yarn gas`

These will produce a gas report for function used in the tests
<br/><br/>

### `yarn dev`

These will run a local hardhat network on `localhost:8545` and deploy your contracts on it. Plus it will watch for any changes and redeploy them.
<br/><br/>

### `yarn local:dev`

This assumes a local node it running on `localhost:8545`. It will deploy your contracts on it. Plus it will watch for any changes and redeploy them.
<br/><br/>

### `yarn execute <network> <file.ts> [args...]`

This will execute the script `<file.ts>` against the specified network
<br/><br/>

### `yarn deploy <network> [args...]`

This will deploy the contract on the specified network.

Behind the scene it uses `hardhat deploy` command so you can append any argument for it
<br/><br/>

### `yarn export <network> <file.json>`

This will export the abi+address of deployed contract to `<file.json>`
<br/><br/>

### `yarn fork:execute <network> [--blockNumber <blockNumber>] [--deploy] <file.ts> [args...]`

This will execute the script `<file.ts>` against a temporary fork of the specified network

if `--deploy` is used, deploy scripts will be executed
<br/><br/>

### `yarn fork:deploy <network> [--blockNumber <blockNumber>] [args...]`

This will deploy the contract against a temporary fork of the specified network.

Behind the scene it uses `hardhat deploy` command so you can append any argument for it
<br/><br/>

### `yarn fork:test <network> [--blockNumber <blockNumber>] [mocha args...]`

This will test the contract against a temporary fork of the specified network.
<br/><br/>

### `yarn fork:dev <network> [--blockNumber <blockNumber>] [args...]`

This will deploy the contract against a fork of the specified network and it will keep running as a node.

Behind the scene it uses `hardhat node` command so you can append any argument for it
