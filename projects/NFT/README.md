# Boilerplate for Ethereum Solidity Smart Contract

Folder Structure

- artifacts: compiled ABI from Hardhat
- cache: cache from Hardhat
- cache_forge: cache from Foundry
- deploy: deploy scripts for hardhat-deploy
- deployments: addresses and ABIs generated after deployment, along with metadata for contract verification
- etherscan_requests: debug files for Ethereum browser
- lib/forge-std: standard library for Foundry
- node_modules: dependencies
- out_forge: compiled ABI output from Foundry (used for unit testing)
- scripts: scripts
- src: contract source code
- test: functional tests
- test_forge: unit test scripts
- typechains: compiled TypeScript interface compatibility files from TypeChain
- utils: deployment-related files provided by the framework (do not modify)

## INSTALL

```bash
git submodule update --init --recursive && yarn
```

## TEST

There are 3 flavors of tests: hardhat, dapptools, and forge

### Hardhat Functional Tests

- One using Hardhat that can leverage hardhat-deploy to reuse deployment procedures and named accounts:

```bash
yarn test
```

### Forge Unit Tests

```bash
forge build && forge test
```

This requires the installation of forge (see [foundry](https://github.com/gakonst/foundry))

## SCRIPTS

Here is the list of npm scripts you can execute:

Some of them rely on [./\_scripts.js](./_scripts.js) to allow parameterizing it via command line argument (have a look inside if you need modifications)
<br/><br/>

### `yarn prepare`

As a standard lifecycle npm script, it is executed automatically upon install. It generates the config file and typechain to get you started with type-safe contract interactions
<br/><br/>

### `yarn format` and `yarn format:fix`

These will perform a format check on your code. The `:fix` version will modify the files to match the requirements specified in `.prettierrc.`
<br/><br/>

### `yarn compile`

This will compile your contracts
<br/><br/>

### `yarn void:deploy`

This will deploy your contracts on the in-memory hardhat network and exit, leaving no trace. It's a quick way to ensure deployments work as intended without consequences
<br/><br/>

### `yarn test [mocha args...]`

This will execute your tests using mocha. You can pass extra arguments to mocha
<br/><br/>

### `yarn coverage`

This will produce a coverage report in the `coverage/` folder
<br/><br/>

### `yarn gas`

This will produce a gas report for functions used in the tests
<br/><br/>

### `yarn dev`

This will run a local hardhat network on `localhost:8545` and deploy your contracts on it. Plus, it will watch for any changes and redeploy them
<br/><br/>

### `yarn local:dev`

This assumes a local node is running on `localhost:8545`. It will deploy your contracts on it. Plus, it will watch for any changes and redeploy them
<br/><br/>

### `yarn execute <network> <file.ts> [args...]`

This will execute the script `<file.ts>` against the specified network
<br/><br/>

### `yarn deploy <network> [args...]`

This will deploy the contract on the specified network.

Behind the scenes, it uses the `hardhat deploy` command so you can append any argument for it
<br/><br/>

### `yarn export <network> <file.json>`

This will export the ABI+address of the deployed contract to `<file.json>`
<br/><br/>

### `yarn fork:execute <network> [--blockNumber <blockNumber>] [--deploy] <file.ts> [args...]`

This will execute the script `<file.ts>` against a temporary fork of the specified network

If `--deploy` is used, deploy scripts will be executed
<br/><br/>

### `yarn fork:deploy <network> [--blockNumber <blockNumber>] [args...]`

This will deploy the contract against a temporary fork of the specified network.

Behind the scenes, it uses the `hardhat deploy` command so you can append any argument for it
<br/><br/>

### `yarn fork:test <network> [--blockNumber <blockNumber>] [mocha args...]`

This will test the contract against a temporary fork of the specified network
<br/><br/>

### `yarn fork:dev <network> [--blockNumber <blockNumber>] [args...]`

This will deploy the contract against a fork of the specified network and it will keep running as a node.

Behind the scenes, it uses the `hardhat node` command so you can append any argument for it

### Contract Verification

Verifying facets and upgradeable contracts

`yarn verify <network>`

Verify diamond market contract

`./scripts/verifyEtherscanDummy.sh <network>`
