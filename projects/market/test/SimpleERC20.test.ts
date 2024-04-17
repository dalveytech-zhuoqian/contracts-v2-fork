import { expect } from "chai";
import {
  ethers,
  deployments,
  getUnnamedAccounts,
  getNamedAccounts,
} from "hardhat";
import { MarketDiamond } from "../typechain-types";
import {  setupUser, setupUsers } from "./utils";

const setup = deployments.createFixture(async () => {
  await deployments.fixture("MarketDiamond");
  const contracts = {
    MarketDiamond: await ethers.getContract<MarketDiamond>("MarketDiamond"),
  };
  const users = await setupUsers(await getUnnamedAccounts(), contracts);
  return {
    ...contracts,
    users,
  };
});

describe("SimpleERC20", function () {
  it("transfer succeed", async function () {
    const { users,  MarketDiamond } = await setup();
  });
});
