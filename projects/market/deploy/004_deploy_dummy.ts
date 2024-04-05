import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { DiamondEtherscanFacet, MarketDiamond } from '../typechain-types'
import { ethers } from 'hardhat'
import { BaseContract } from 'ethers'
import { waitFor } from '../utils/wait'

async function setupUser<T extends { [contractName: string]: BaseContract }>(
    address: string,
    contracts: T
): Promise<{ address: string } & T> {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const user: any = { address }
    for (const key of Object.keys(contracts)) {
        user[key] = contracts[key].connect(await ethers.getSigner(address))
    }
    return user as { address: string } & T
}

async function setAccessManagerAddress(hre: HardhatRuntimeEnvironment): Promise<void> {
    const { deployments, getNamedAccounts } = hre
    const { deployer } = await getNamedAccounts()

    const DummyDiamondImplementation = (await deployments.get('DummyDiamondImplementation')).address
    const DiamondEtherscanFacet = await ethers.getContract<DiamondEtherscanFacet>('MarketDiamond')
    const deployerDeployments = await setupUser(deployer, { MarketDiamond: DiamondEtherscanFacet })
    if (await deployerDeployments.MarketDiamond.implementation() !== DummyDiamondImplementation) {
        console.log("implementations don't match, setting new implementation")
        await waitFor(deployerDeployments.MarketDiamond.setDummyImplementation(DummyDiamondImplementation))
    } else {
        console.log('implementations match, no need to set new implementation')
    }

}
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    await deploy('DummyDiamondImplementation', {
        from: deployer,
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    })
    await setAccessManagerAddress(hre)
}

export default func
func.tags = ['DummyDiamondImplementation']
func.dependencies = ['MarketDiamond']

