import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { BlexSBT } from "../typechain-types";
import { waitFor } from "../utils/wait";
import roleIds from "../utils/roleIds";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments,getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  await deploy("BlexSBT",{
    from: deployer,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: ["BlexSBT","BlexSBT"]
        }
      }
    },
    log: true,
    autoMine: true // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });
};
export default func;
func.tags = ["BlexSBT"];
