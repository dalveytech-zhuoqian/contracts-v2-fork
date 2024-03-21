const { ethers } = require("ethers");
const {
  DefenderRelaySigner,
  DefenderRelayProvider
} = require("defender-relay-client/lib/ethers");

// Replace with your contract ABI
const autoOrderV2ABI = [
  {
    inputs: [
      {
        internalType: "bytes",
        name: "checkData",
        type: "bytes"
      }
    ],
    name: "checkUpkeep",
    outputs: [
      {
        internalType: "bool",
        name: "upkeepNeeded",
        type: "bool"
      },
      {
        internalType: "bytes",
        name: "performData",
        type: "bytes"
      }
    ],
    stateMutability: "view",
    type: "function"
  },

  {
    inputs: [
      {
        internalType: "bytes",
        name: "performData",
        type: "bytes"
      }
    ],
    name: "performUpkeep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  }
];

const BlexMutiCallABI = [
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "calls",
        type: "bytes[]"
      }
    ],
    name: "aggregateCall",
    outputs: [
      {
        internalType: "bytes[]",
        name: "returnData",
        type: "bytes[]"
      }
    ],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "calls",
        type: "bytes[]"
      }
    ],
    name: "aggregateStaticCall",
    outputs: [
      {
        internalType: "bytes[]",
        name: "returnData",
        type: "bytes[]"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "bytes[]",
        name: "calls",
        type: "bytes[]"
      }
    ],
    name: "blockAndAggregate",
    outputs: [
      {
        internalType: "uint256",
        name: "blockNumber",
        type: "uint256"
      },
      {
        internalType: "bytes32",
        name: "blockHash",
        type: "bytes32"
      },
      {
        components: [
          {
            internalType: "bool",
            name: "success",
            type: "bool"
          },
          {
            internalType: "bytes",
            name: "returnData",
            type: "bytes"
          }
        ],
        internalType: "struct BlexMulticall.Result[]",
        name: "returnData",
        type: "tuple[]"
      }
    ],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "blockNumber",
        type: "uint256"
      }
    ],
    name: "getBlockHash",
    outputs: [
      {
        internalType: "bytes32",
        name: "blockHash",
        type: "bytes32"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getBlockNumber",
    outputs: [
      {
        internalType: "uint256",
        name: "blockNumber",
        type: "uint256"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getCurrentBlockCoinbase",
    outputs: [
      {
        internalType: "address",
        name: "coinbase",
        type: "address"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getCurrentBlockDifficulty",
    outputs: [
      {
        internalType: "uint256",
        name: "difficulty",
        type: "uint256"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getCurrentBlockGasLimit",
    outputs: [
      {
        internalType: "uint256",
        name: "gaslimit",
        type: "uint256"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getCurrentBlockTimestamp",
    outputs: [
      {
        internalType: "uint256",
        name: "timestamp",
        type: "uint256"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "addr",
        type: "address"
      }
    ],
    name: "getEthBalance",
    outputs: [
      {
        internalType: "uint256",
        name: "balance",
        type: "uint256"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "getLastBlockHash",
    outputs: [
      {
        internalType: "bytes32",
        name: "blockHash",
        type: "bytes32"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "requireSuccess",
        type: "bool"
      },
      {
        internalType: "bytes[]",
        name: "calls",
        type: "bytes[]"
      }
    ],
    name: "tryAggregate",
    outputs: [
      {
        components: [
          {
            internalType: "bool",
            name: "success",
            type: "bool"
          },
          {
            internalType: "bytes",
            name: "returnData",
            type: "bytes"
          }
        ],
        internalType: "struct BlexMulticall.Result[]",
        name: "returnData",
        type: "tuple[]"
      }
    ],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "bool",
        name: "requireSuccess",
        type: "bool"
      },
      {
        internalType: "bytes[]",
        name: "calls",
        type: "bytes[]"
      }
    ],
    name: "tryBlockAndAggregate",
    outputs: [
      {
        internalType: "uint256",
        name: "blockNumber",
        type: "uint256"
      },
      {
        internalType: "bytes32",
        name: "blockHash",
        type: "bytes32"
      },
      {
        components: [
          {
            internalType: "bool",
            name: "success",
            type: "bool"
          },
          {
            internalType: "bytes",
            name: "returnData",
            type: "bytes"
          }
        ],
        internalType: "struct BlexMulticall.Result[]",
        name: "returnData",
        type: "tuple[]"
      }
    ],
    stateMutability: "nonpayable",
    type: "function"
  }
];

const autoLiqABI = [
  {
    inputs: [
      {
        internalType: "bytes",
        name: "checkData",
        type: "bytes"
      }
    ],
    name: "checkUpkeep",
    outputs: [
      {
        internalType: "bool",
        name: "upkeepNeeded",
        type: "bool"
      },
      {
        internalType: "bytes",
        name: "performData",
        type: "bytes"
      }
    ],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "performData",
        type: "bytes"
      }
    ],
    name: "performUpkeep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  }
];

const addressJSON = {
  AutoOrderV2: "0x3ECD1eB4742823F4C9Ea35504994764305ca3247",
  BlexMutiCall: "0x57E5442bD149cf2D19002EF8c761582Fa8cfeA46",
  Market: "0xd9CD2FEAF3453d8cA9b26E1F17F583b414B4A2b8",
  AutoLiq: "0x7ce298Ad682bE6B8E74C2d3154A0ecE3B2461a0B"
};

function blexMutiCallContract(signer) {
  const contract = new ethers.Contract(
    addressJSON.BlexMutiCall,
    BlexMutiCallABI,
    signer
  );
  return contract;
}

function autoOrderContract() {
  return new ethers.Contract(addressJSON.AutoOrderV2, autoOrderV2ABI);
}

function liqContract() {
  return new ethers.Contract(addressJSON.AutoLiq, autoLiqABI);
}

function encodeOrderPerformUpkeepData(checkData) {
  const autoOrder = new ethers.Contract(
    addressJSON.AutoOrderV2,
    autoOrderV2ABI
  );
  return ethers.utils.defaultAbiCoder.encode(
    ["address", "bytes"],
    [
      addressJSON.AutoOrderV2,
      autoOrder.interface.encodeFunctionData("performUpkeep", [checkData])
    ]
  );
}

function encodeLiqPerformUpkeepData(checkData) {
  const autoOrder = new ethers.Contract(addressJSON.AutoLiq, autoLiqABI);
  return ethers.utils.defaultAbiCoder.encode(
    ["address", "bytes"],
    [
      addressJSON.AutoLiq,
      autoOrder.interface.encodeFunctionData("performUpkeep", [checkData])
    ]
  );
}

function encodeOrderCheckData(contract, marketAddress) {
  const checkDatas = [];
  for (let isLong = 0; isLong < 2; isLong++) {
    for (let isIncrease = 0; isIncrease < 2; isIncrease++) {
      const data = ethers.utils.defaultAbiCoder.encode(
        ["address", "bool", "bool", "uint256", "uint256"],
        [
          marketAddress, // ETH market
          isLong == 0, // Replace with isLong
          isIncrease == 0, // Replace with isIncrease
          0, // Replace with _lower
          9999 // Replace with _upper
        ]
      );
      checkDatas.push(
        ethers.utils.defaultAbiCoder.encode(
          ["address", "bytes"],
          [
            addressJSON.AutoOrderV2,
            contract.interface.encodeFunctionData("checkUpkeep", [data])
          ]
        )
      );
    }
  }
  return checkDatas;
}

function encodeLiqCheckData(contract, marketAddress) {
  const checkData = ethers.utils.defaultAbiCoder.encode(
    ["address"],
    [marketAddress]
  );
  return [
    ethers.utils.defaultAbiCoder.encode(
      ["address", "bytes"],
      [
        addressJSON.AutoLiq,
        contract.interface.encodeFunctionData("checkUpkeep", [checkData])
      ]
    )
  ];
}

async function callCheckUpKeep(contract, orderDatas, liqDatas) {
  orderDatas.push(...liqDatas);
  try {
    const results = await contract.aggregateStaticCall(orderDatas);
    const response = [];
    for (let index = 0; index < results.length; index++) {
      response.push(
        ethers.utils.defaultAbiCoder.decode(["bool", "bytes"], results[index])
      );
    }
    return response;
  } catch (error) {
    console.error("Error:", error);
  }
}

exports.handler = async function (credentials) {
  const provider = new DefenderRelayProvider(credentials);
  const signer = new DefenderRelaySigner(credentials, provider, {
    speed: "fast"
  });

  const blexMutiCall = blexMutiCallContract(signer);
  const autoOrder = autoOrderContract();
  const liq = liqContract();
  const checkOrderDatas = encodeOrderCheckData(autoOrder, addressJSON.Market);
  const checkLiqDatas = encodeLiqCheckData(liq, addressJSON.Market);
  const performDatas = await callCheckUpKeep(
    blexMutiCall,
    checkOrderDatas,
    checkLiqDatas
  );
  const executeArrs = [];
  for (let index = 0; index < performDatas.length; index++) {
    if (performDatas[index][0] && index < performDatas.length - 1) {
      executeArrs.push(encodeOrderPerformUpkeepData(performDatas[index][1]));
    }
    if (performDatas[index][0] && index == performDatas.length - 1) {
      executeArrs.push(encodeLiqPerformUpkeepData(performDatas[index][1]));
    }
  }
  if (executeArrs.length != 0) {
    return await blexMutiCall.tryAggregate(false, executeArrs, {
      gasLimit: "20000000"
    });
  }
};

// To run locally (this code will not be executed in Autotasks)
if (require.main === module) {
  require("dotenv").config();
  const { API_KEY: apiKey, API_SECRET: apiSecret } = process.env;
  exports
    .handler({ apiKey, apiSecret })
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}
