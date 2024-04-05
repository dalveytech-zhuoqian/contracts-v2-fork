import 'dotenv/config'
import { HardhatUserConfig } from 'hardhat/types'

import '@nomicfoundation/hardhat-chai-matchers'
import '@nomicfoundation/hardhat-ethers'
import '@typechain/hardhat'
import 'hardhat-gas-reporter'
import 'solidity-coverage'

import 'hardhat-deploy'
import 'hardhat-deploy-ethers'
import 'hardhat-deploy-tenderly'

import { node_url, accounts, addForkConfiguration } from './utils/network'

const config: HardhatUserConfig = {
	typechain: {
		externalArtifacts: ['deployments/localhost/MarketDiamond.json']
	},
	solidity: {
		compilers: [
			{
				version: '0.8.20',
				settings: {
					optimizer: {
						enabled: false,
						runs: 1,
					},
				},
			},
		],
	},
	namedAccounts: {
		deployer: 10,
		simpleERC20Beneficiary: 11,
		diamondAdmin: 10,
		accessManagerAdmin: 10
	},
	networks: addForkConfiguration({
		hardhat: {
			initialBaseFeePerGas: 0, // to fix : https://github.com/sc-forks/solidity-coverage/issues/652, see https://github.com/sc-forks/solidity-coverage/issues/652#issuecomment-896330136
		},
		localhost: {
			url: node_url('localhost'),
			accounts: accounts(),
		},
		fantom_test: {
			url: node_url('fantom_test'),
			accounts: accounts(),
			verify: {
				etherscan: {
					apiKey: process.env.ETHERSCAN_API_KEY_FANTOM,
					apiUrl: 'https://api-testnet.ftmscan.com',
				}
			}
		},
		base_sepolia: {
			url: node_url('base_sepolia'),
			accounts: accounts(),
			verify: {
				etherscan: {
					apiUrl: 'https://api-sepolia.basescan.org',
					apiKey: process.env.ETHERSCAN_API_KEY_BASE,
				}
			}
		},
		staging: {
			url: node_url('rinkeby'),
			accounts: accounts('rinkeby'),
		},
		production: {
			url: node_url('mainnet'),
			accounts: accounts('mainnet'),
		},
		mainnet: {
			url: node_url('mainnet'),
			accounts: accounts('mainnet'),
		},
		sepolia: {
			url: node_url('sepolia'),
			accounts: accounts('sepolia'),
		},
		kovan: {
			url: node_url('kovan'),
			accounts: accounts('kovan'),
		},
		goerli: {
			url: node_url('goerli'),
			accounts: accounts('goerli'),
		},
	}),
	paths: {
		sources: 'src',
	},
	gasReporter: {
		currency: 'USD',
		gasPrice: 100,
		enabled: process.env.REPORT_GAS ? true : false,
		coinmarketcap: process.env.COINMARKETCAP_API_KEY,
		maxMethodDiff: 10,
	},
	mocha: {
		timeout: 0,
	},
	external: process.env.HARDHAT_FORK
		? {
			deployments: {
				// process.env.HARDHAT_FORK will specify the network that the fork is made from.
				// these lines allow it to fetch the deployments from the network being forked from both for node and deploy task
				hardhat: ['deployments/' + process.env.HARDHAT_FORK],
				localhost: ['deployments/' + process.env.HARDHAT_FORK],
			},
		}
		: undefined,

	tenderly: {
		project: process.env.TENDERLY_PROJECT as string,
		username: process.env.TENDERLY_USERNAME as string,
	},
}

export default config
