import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { BaseContract } from "ethers";
import { BlexAccessManager } from "../typechain-types";
import { waitFor } from "../utils/wait";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;
  const { deploy } = deployments;

  const { deployer, accessManagerAdmin } = await getNamedAccounts();
  console.log("deployer", deployer);
  console.log("accessManagerAdmin", accessManagerAdmin);

  await deploy("BlexAccessManager", {
    from: deployer,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: [accessManagerAdmin],
        },
      },
    },
    log: true,
    autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  });

  const BlexAccessManager =
    await ethers.getContract<BlexAccessManager>("BlexAccessManager");
  const deployerSigner = await ethers.getSigner(deployer);
  await waitFor(
    BlexAccessManager.connect(deployerSigner).grantRole(1, deployer, 0),
  );
};
export default func;
func.tags = ["BlexAccessManager"];
