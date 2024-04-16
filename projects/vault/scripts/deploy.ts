import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const authAddress = "0x00";

  // deploy Vault Beacon
  const Vault = await ethers.getContractFactory("Vault");
  const vaultBeacon = await upgrades.deployBeacon(Vault);
  await vaultBeacon.waitForDeployment();

  // deploy VaultReward Beacon
  const VaultReward = await ethers.getContractFactory("VaultReward");
  const vaultRewardBeacon = await upgrades.deployBeacon(VaultReward);
  await vaultRewardBeacon.waitForDeployment();

  // deploy RewardDistributor Beacon
  const RewardDistributor =
    await ethers.getContractFactory("RewardDistributor");
  const rewardDistributorBeacon =
    await upgrades.deployBeacon(RewardDistributor);
  await rewardDistributorBeacon.waitForDeployment();

  // deploy VaultFactory
  const VaultFactory = await ethers.getContractFactory("VaultFactory");
  const vaultFactory = await upgrades.deployProxy(VaultFactory, [
    vaultBeacon.address,
    authAddress,
  ]);
  await vaultFactory.waitForDeployment();

  // deploy VaultRewardFactory
  const VaultRewardFactory =
    await ethers.getContractFactory("VaultRewardFactory");
  const vaultRewardFactory = await upgrades.deployProxy(VaultRewardFactory, [
    vaultRewardBeacon.address,
    authAddress,
  ]);
  await vaultRewardFactory.waitForDeployment();

  // deploy RewardDistributorFacotry
  const RewardDistributorFactory = await ethers.getContractFactory(
    "RewardDistributorFactory",
  );
  const rewardDistributorFactory = await upgrades.deployProxy(
    RewardDistributorFactory,
    [rewardDistributorBeacon.address, authAddress],
  );
  await rewardDistributorFactory.waitForDeployment();

  // deploy VaultBuilder
  const VaultBuilder = await ethers.getContractFactory("VaultBuilder");
  const vaultBuilder = await upgrades.deployProxy(VaultBuilder, [
    vaultFactory.target,
    vaultRewardFactory.target,
    rewardDistributorFactory.target,
    authAddress,
  ]);
  await vaultBuilder.waitForDeployment();
  console.log("VaultBuilder deployed to:", vaultBuilder.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
