import { ethers, network } from "hardhat";
import { getSolidityFunctionSignature, handleTx } from "./utils";
import { addressJson, roleIDJson, grantDelayTime } from "./config";

const IMMEDIATE_TIME = 0;

const ProxyAdminABI = [
  {
    constant: true,
    inputs: [
      {
        name: "proxy",
        type: "address",
      },
    ],
    name: "getProxyImplementation",
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "proxy",
        type: "address",
      },
      {
        name: "newAdmin",
        type: "address",
      },
    ],
    name: "changeProxyAdmin",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "owner",
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: true,
    inputs: [],
    name: "isOwner",
    outputs: [
      {
        name: "",
        type: "bool",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "proxy",
        type: "address",
      },
      {
        name: "implementation",
        type: "address",
      },
      {
        name: "data",
        type: "bytes",
      },
    ],
    name: "upgradeAndCall",
    outputs: [],
    payable: true,
    stateMutability: "payable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "proxy",
        type: "address",
      },
      {
        name: "implementation",
        type: "address",
      },
    ],
    name: "upgrade",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
      {
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: true,
    inputs: [
      {
        name: "proxy",
        type: "address",
      },
    ],
    name: "getProxyAdmin",
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
    payable: false,
    stateMutability: "view",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
];

async function main() {
  const [owner] = await ethers.getSigners();
  const addressJsonNetwork = addressJson[network.name];
  const AccessManager = await ethers.getContractAt(
    "AccessManagerUpgradeable",
    addressJsonNetwork.accessManager,
    owner,
  );
  const ProxyAdmin = new ethers.Contract(
    addressJsonNetwork.proxyAdmin,
    ProxyAdminABI,
    owner,
  );
  await handleTx(
    AccessManager.grantRole(
      roleIDJson.scheduler,
      addressJsonNetwork.scheduler,
      grantDelayTime,
    ),
    "grantRole scheduler role",
  );
  await handleTx(
    AccessManager.grantRole(
      roleIDJson.guardian,
      addressJsonNetwork.guardian,
      grantDelayTime,
    ),
    "grantRole guardian role",
  );
  await handleTx(
    AccessManager.setTargetFunctionRole(
      addressJsonNetwork.rewardDistributor,
      [getSolidityFunctionSignature("setTokensPerInterval(uint256)")],
      roleIDJson.scheduler,
    ),
    "setTargetFunctionRole rewardDistributor setTokensPerInterval",
  );
  await handleTx(
    AccessManager.setTargetFunctionRole(
      addressJsonNetwork.vaultReward,
      [getSolidityFunctionSignature("setAPR(uint256)")],
      roleIDJson.scheduler,
    ),
    "setTargetFunctionRole vaultReward setAPR",
  );
  await handleTx(
    AccessManager.setRoleGuardian(roleIDJson.scheduler, roleIDJson.guardian),
    "related scheduler to guardian",
  );
  await handleTx(
    AccessManager.grantRole(
      roleIDJson.admin,
      addressJsonNetwork.boss,
      IMMEDIATE_TIME,
    ),
    "grantRole admin role to boss",
  );

  await handleTx(
    ProxyAdmin.transferOwnership(addressJsonNetwork.boss),
    "transferOwnership to boss",
  );
  await handleTx(
    AccessManager.revokeRole(roleIDJson.admin, owner.address),
    "revokeRole deployer(operator) admin role ",
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
