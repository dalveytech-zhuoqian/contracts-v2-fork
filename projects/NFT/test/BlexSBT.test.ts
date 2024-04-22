// test BlexSBT contracts
import {
  ethers,
  deployments,
  getUnnamedAccounts,
  getNamedAccounts,
} from "hardhat";
import { BlexSBT } from "../typechain-types";
import { waitFor } from "../utils/wait";
import roleIds from "../utils/roleIds";
import { setupUser, setupUsers } from "./utils";
import { expect } from "chai";

const setup = deployments.createFixture(async () => {
  await deployments.fixture("BlexSBT");
  const { deployer } = await getNamedAccounts();

  const contracts = {
    BlexSBT: await ethers.getContract<BlexSBT>("BlexSBT"),
  };
  const users = await setupUsers(await getUnnamedAccounts(), contracts);
  return {
    ...contracts,
    users,
    deployer: await setupUser(deployer, contracts),
  };
});

describe("BlexSBT", function () {
  it("initialize revert", async function () {
    const { deployer, users } = await setup();
    const handle = deployer.BlexSBT.initialize("name", "symbol");
    await expect(handle).to.be.reverted;
  });

  it("transferContractOwnership", async function () {
    const { deployer, users } = await setup();
    const handle = users[0].BlexSBT.transferContractOwnership(users[0].address);
    await expect(handle).to.be.reverted;
  });

  it("issueDegrees reverted", async function () {
    const { deployer, users } = await setup();
    await expect(users[0].BlexSBT.issueDegrees([users[0].address])).to.be
      .reverted;
  });

  it("issueDegrees sucessful", async function () {
    const { deployer, users } = await setup();

    await waitFor(deployer.BlexSBT.issueDegrees([users[0].address]));
    // check issuedDegrees
    const issueState = await deployer.BlexSBT.issuedDegrees(users[0].address);
    expect(issueState).to.be.true;
  });

  it("issueDegrees and claimDegree", async function () {
    const { deployer, users } = await setup();
    await waitFor(deployer.BlexSBT.issueDegrees([users[0].address]));

    // claimDegree
    const tokenURI = "https://ipfs.io/ipfs/QmZz1";
    const handle = users[0].BlexSBT.claimDegree(tokenURI);
    await waitFor(handle);

    // check token URI
    const uri = await users[0].BlexSBT.tokenURI(1);
    expect(uri).to.be.equal(tokenURI);
  });

  it("issueDegrees and claimDegree twice will be reverted", async function () {
    const { deployer, users } = await setup();
    await waitFor(deployer.BlexSBT.issueDegrees([users[0].address]));

    // claimDegree
    const tokenURI = "https://ipfs.io/ipfs/QmZz1";
    const handle = users[0].BlexSBT.claimDegree(tokenURI);
    await waitFor(handle);

    {
      // same user claimDegree different tokenURI will be reverted
      const tokenURI3 = "https://ipfs.io/ipfs/QmZz2";
      const handle3 = users[0].BlexSBT.claimDegree(tokenURI3);
      await expect(handle3).to.be.revertedWith("Degree is not issued");
    }
  });
});
