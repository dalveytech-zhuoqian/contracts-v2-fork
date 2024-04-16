import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { BlexAccessManager, BLEX } from "../typechain-types";
import { waitFor } from "../utils/wait";
import roleIds from "../utils/roleIds";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const BlexAccessManager = await ethers.getContract<BlexAccessManager>("BlexAccessManager");
  await deploy("BLEX", {
    from: deployer,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: [await BlexAccessManager.getAddress()]
        }
      }
    },
    log: true,
    autoMine: true // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });
  const targetContract = await ethers.getContract<BLEX>("BLEX");
  {
    const selectors = [
      targetContract.interface.getFunction("mint").selector, // owner
      targetContract.interface.getFunction("setBaseURI").selector // owner
    ];
    await waitFor(
      BlexAccessManager.connect(await ethers.getSigner(deployer)).setTargetFunctionRole(
        targetContract.target,
        selectors,
        roleIds.owner
      )
    );
  }
};
export default func;
func.tags = ["BLEX"];
func.dependencies = ["BlexAccessManager"];
