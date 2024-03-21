import { ethers, } from "hardhat";
 
const MarketReaderABI = [
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_f",
                "type": "address"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": false,
                "internalType": "uint8",
                "name": "version",
                "type": "uint8"
            }
        ],
        "name": "Initialized",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "previousOwner",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "OwnershipTransferred",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "previousAdminRole",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "newAdminRole",
                "type": "bytes32"
            }
        ],
        "name": "RoleAdminChanged",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            }
        ],
        "name": "RoleGranted",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "sender",
                "type": "address"
            }
        ],
        "name": "RoleRevoked",
        "type": "event"
    },
    {
        "inputs": [],
        "name": "DEFAULT_ADMIN_ROLE",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "market",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "isLong",
                "type": "bool"
            }
        ],
        "name": "availableLiquidity",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "fac",
        "outputs": [
            {
                "internalType": "contract IMarketFactory",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "market",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "isLong",
                "type": "bool"
            }
        ],
        "name": "getFundingFee",
        "outputs": [
            {
                "internalType": "int256",
                "name": "",
                "type": "int256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_market",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "_isLong",
                "type": "bool"
            }
        ],
        "name": "getFundingRate",
        "outputs": [
            {
                "internalType": "int256",
                "name": "",
                "type": "int256"
            },
            {
                "internalType": "int256",
                "name": "",
                "type": "int256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_marketAddr",
                "type": "address"
            }
        ],
        "name": "getMarket",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "minSlippage",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "maxSlippage",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "slippageDigits",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "minLev",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "maxLev",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "minCollateral",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "maxTradeAmount",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "allowOpen",
                        "type": "bool"
                    },
                    {
                        "internalType": "bool",
                        "name": "allowClose",
                        "type": "bool"
                    }
                ],
                "internalType": "struct IMarketReader.ValidOuts",
                "name": "validOuts",
                "type": "tuple"
            },
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "tokenDigits",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "closeFeeRate",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "openFeeRate",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "liquidationFeeUsd",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "spread",
                        "type": "uint256"
                    },
                    {
                        "internalType": "address",
                        "name": "indexToken",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "collateralToken",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "orderBookLong",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "orderBookShort",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "positionBook",
                        "type": "address"
                    }
                ],
                "internalType": "struct IMarketReader.MarketOuts",
                "name": "mktOuts",
                "type": "tuple"
            },
            {
                "components": [
                    {
                        "internalType": "uint256",
                        "name": "closeFeeRate",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "openFeeRate",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "execFee",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "liquidateFee",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "digits",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct IMarketReader.FeeOuts",
                "name": "feeOuts",
                "type": "tuple"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getMarkets",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "string",
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "internalType": "address",
                        "name": "addr",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "minPay",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "allowOpen",
                        "type": "bool"
                    },
                    {
                        "internalType": "bool",
                        "name": "allowClose",
                        "type": "bool"
                    }
                ],
                "internalType": "struct IMarketFactory.Outs[]",
                "name": "_outs",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "market",
                "type": "address"
            }
        ],
        "name": "getPositions",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "address",
                        "name": "market",
                        "type": "address"
                    },
                    {
                        "internalType": "bool",
                        "name": "isLong",
                        "type": "bool"
                    },
                    {
                        "internalType": "uint32",
                        "name": "lastTime",
                        "type": "uint32"
                    },
                    {
                        "internalType": "uint216",
                        "name": "extra3",
                        "type": "uint216"
                    },
                    {
                        "internalType": "uint256",
                        "name": "size",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "collateral",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "averagePrice",
                        "type": "uint256"
                    },
                    {
                        "internalType": "int256",
                        "name": "entryFundingRate",
                        "type": "int256"
                    },
                    {
                        "internalType": "int256",
                        "name": "realisedPnl",
                        "type": "int256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "extra0",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "extra1",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "extra2",
                        "type": "uint256"
                    }
                ],
                "internalType": "struct Position.Props[]",
                "name": "_positions",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            }
        ],
        "name": "getRoleAdmin",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_account",
                "type": "address"
            }
        ],
        "name": "grantControllerRoleByMarketManager",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "grantRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "hasRole",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_marketRouter",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_vaultRouter",
                "type": "address"
            }
        ],
        "name": "initialize",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "market",
                "type": "address"
            },
            {
                "internalType": "address",
                "name": "_account",
                "type": "address"
            },
            {
                "internalType": "bool",
                "name": "_isLong",
                "type": "bool"
            }
        ],
        "name": "isLiquidate",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "_state",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "marketRouter",
        "outputs": [
            {
                "internalType": "contract IMarketRouter",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "renounceOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "renounceRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes32",
                "name": "role",
                "type": "bytes32"
            },
            {
                "internalType": "address",
                "name": "account",
                "type": "address"
            }
        ],
        "name": "revokeRole",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes4",
                "name": "interfaceId",
                "type": "bytes4"
            }
        ],
        "name": "supportsInterface",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "to",
                "type": "address"
            }
        ],
        "name": "transferAdmin",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "newOwner",
                "type": "address"
            }
        ],
        "name": "transferOwnership",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "vaultRouter",
        "outputs": [
            {
                "internalType": "contract IVaultRouter",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
]

const BlexMutiCallABI = [
    {
        "inputs": [
            {
                "internalType": "bytes[]",
                "name": "calls",
                "type": "bytes[]"
            }
        ],
        "name": "aggregateCall",
        "outputs": [
            {
                "internalType": "bytes[]",
                "name": "returnData",
                "type": "bytes[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes[]",
                "name": "calls",
                "type": "bytes[]"
            }
        ],
        "name": "aggregateStaticCall",
        "outputs": [
            {
                "internalType": "bytes[]",
                "name": "returnData",
                "type": "bytes[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bytes[]",
                "name": "calls",
                "type": "bytes[]"
            }
        ],
        "name": "blockAndAggregate",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "blockNumber",
                "type": "uint256"
            },
            {
                "internalType": "bytes32",
                "name": "blockHash",
                "type": "bytes32"
            },
            {
                "components": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    },
                    {
                        "internalType": "bytes",
                        "name": "returnData",
                        "type": "bytes"
                    }
                ],
                "internalType": "struct BlexMulticall.Result[]",
                "name": "returnData",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "blockNumber",
                "type": "uint256"
            }
        ],
        "name": "getBlockHash",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "blockHash",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getBlockNumber",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "blockNumber",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentBlockCoinbase",
        "outputs": [
            {
                "internalType": "address",
                "name": "coinbase",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentBlockDifficulty",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "difficulty",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentBlockGasLimit",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "gaslimit",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getCurrentBlockTimestamp",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "timestamp",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "addr",
                "type": "address"
            }
        ],
        "name": "getEthBalance",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "balance",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getLastBlockHash",
        "outputs": [
            {
                "internalType": "bytes32",
                "name": "blockHash",
                "type": "bytes32"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bool",
                "name": "requireSuccess",
                "type": "bool"
            },
            {
                "internalType": "bytes[]",
                "name": "calls",
                "type": "bytes[]"
            }
        ],
        "name": "tryAggregate",
        "outputs": [
            {
                "components": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    },
                    {
                        "internalType": "bytes",
                        "name": "returnData",
                        "type": "bytes"
                    }
                ],
                "internalType": "struct BlexMulticall.Result[]",
                "name": "returnData",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "bool",
                "name": "requireSuccess",
                "type": "bool"
            },
            {
                "internalType": "bytes[]",
                "name": "calls",
                "type": "bytes[]"
            }
        ],
        "name": "tryBlockAndAggregate",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "blockNumber",
                "type": "uint256"
            },
            {
                "internalType": "bytes32",
                "name": "blockHash",
                "type": "bytes32"
            },
            {
                "components": [
                    {
                        "internalType": "bool",
                        "name": "success",
                        "type": "bool"
                    },
                    {
                        "internalType": "bytes",
                        "name": "returnData",
                        "type": "bytes"
                    }
                ],
                "internalType": "struct BlexMulticall.Result[]",
                "name": "returnData",
                "type": "tuple[]"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    }
]

const addressJSON = {
    "MarketReader": "0x32f298Ebb9C1D7CA2b22bF956048C7A2d4b50487",
    "Muticall": "0xF947F005fAD62789d3554b01F06841e521F2a3c2",
    "Account": "0x8A153Cf32b5Db00F4014Adf0F3BFA652Ed38bD84",
    "Market": "0xd9CD2FEAF3453d8cA9b26E1F17F583b414B4A2b8",
    "isLong": true
}

/*通过muticall合约将
//1.marketReader.getFundingFee
//2.marketReader.getMarket => market.feeOuts.openFeeRate
//3.marketReader.getMarket => market.feeOuts.closeFeeRate
//4.marketreader.getPositions
//通过一次请求获取
*/
async function encodeData(account: string, market: string, isLong: boolean) {
    // 创建一个新的合约对象
    const MarketReader = new ethers.Contract(addressJSON.MarketReader, MarketReaderABI);

    // 定义一个数组，用于存储 encoded 数据
    const calldata = new Array(3);

    // 使用 ethers.AbiCoder 对象来编码数据
    const abicode = ethers.AbiCoder.defaultAbiCoder();

    // 编码第1个数据
    calldata[0] = abicode.encode(
        [
            "address",
            "bytes"
        ],
        [
            addressJSON.MarketReader,
            MarketReader.interface.encodeFunctionData("getFundingFee", [account, market, isLong])
        ]);

    // 编码第2个数据
    calldata[1] = abicode.encode(
        [
            "address",
            "bytes"
        ],
        [addressJSON.MarketReader, MarketReader.interface.encodeFunctionData("getMarket", [market])]
    );

    // 编码第3个数据
    calldata[2] = abicode.encode([
        "address",
        "bytes"
    ], [addressJSON.MarketReader, MarketReader.interface.encodeFunctionData("getPositions", [account, market])]);


    // 返回编码后的数据
    return calldata;
}

async function main() {
    const startTime = performance.now();

  // ------------------------------------------
  // STEP1: 编码数据
  const [owner] = await ethers.getSigners();
  const calldata = await encodeData(
    addressJSON.Account,
    addressJSON.Market,
    addressJSON.isLong
  ); // 返回编码之后的数据
  // 如果有多个 market, 这里应该把编码之后的数组做一下拼接. 例如: calldataConcat = calldataETH.concat(calldataBTC)

  // ------------------------------------------
  // STEP2: 调用合约
  const Muticall = new ethers.Contract(
    addressJSON.Muticall,
    BlexMutiCallABI,
    owner
  );
  const results = await Muticall.aggregateStaticCall(calldata);

  // ------------------------------------------
  // STEP3: 解析数据
  const abicode = ethers.AbiCoder.defaultAbiCoder();

  // a. 解析第一个返回值(getFundingFee)
  const fundingfee = abicode.decode(["int256"], results[0])[0].toString(); //返回值为bigInt  转换成string

  // b. 解析第二个返回值(getMarket)
  // 将openFeeRate和closeFeeRate解析出来
  //分别为数组下标的第19和20
  const feeOuts = abicode.decode(
    [
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "bool",
      "bool",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "address",
      "address",
      "address",
      "address",
      "address",
      "uint256",
      "uint256",
      "uint256",
      "uint256",
      "uint256"
    ],
    results[1]
  );

  const closeFeeRate = feeOuts[19].toString();
  const openFeeRate = feeOuts[20].toString();
    
  // c. 解析第二个返回值(getMarket)
  const position = abicode.decode(
    [
      "tuple(address,bool,uint32,uint216,uint256,uint256,uint256,int256,int256,uint256,uint256,uint256)[]"
    ],
    results[2]
  )[0];
  console.log(
    `Funding fee: ${fundingfee},\n Close fee rate: ${closeFeeRate},\n Open fee rate: ${openFeeRate},\n Position: ${position[0]}\n`
  );
    const endTime = performance.now();
const timeTaken = endTime - startTime;

console.log(`Execution time: ${timeTaken} milliseconds`);

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
