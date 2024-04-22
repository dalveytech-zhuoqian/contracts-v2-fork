import { ethers,deployments,getNamedAccounts } from "hardhat";
import { BlexSBT } from "../typechain-types";
import { waitFor } from "../utils/wait";

async function mint(addressList: string[],uriList: string[]) {
  const { deployer } = await getNamedAccounts();
  console.log(deployer);
  const targetContract = await ethers.getContract<BlexSBT>("BlexSBT");
  await waitFor(targetContract.connect(await ethers.getSigner(deployer)).issueDegreeList(addressList,uriList));
  console.log("mint success");
}

async function main() {
  // read mint list from file
  const addressList = ["0xEa985d6ae63F26b1d3246AD81c5B01c2E6239966","0xD2A47d453a6203f0B6b14e41d0b3B63E1C129A9f"];
  const uriList = ["1","2"]
  await mint(addressList,uriList);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
