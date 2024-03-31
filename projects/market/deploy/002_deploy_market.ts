import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'
import { AccessManagedFacet } from '../typechain-types'
import { BaseContract } from 'ethers'

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

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre
    const { diamond } = deployments

    const { deployer } = await getNamedAccounts()

    const MarketDiamondDeployment = await diamond.deploy('MarketDiamond', {
        from: deployer,
        facets: [
            "MarketFacet",
            "AccessManagedFacet",
            "FeeFacet",
            "OracleFacet",
            "OrderFacet",
            "PositionAddFacet",
            "PositionSubFacet",
            "ReferralFacet",
            "MarketReaderFacet"
        ], // will prepend TestDiamond_facet_ to each facet name
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    })

    // set AccessManager address in MarketDiamond
    const accessManagerAddress = (await deployments.get('BlexAccessManager')).address
    const marketDiamondAccessManagedFacet = await ethers.getContract<AccessManagedFacet>('MarketDiamond')
    const deployerDeployments = await setupUser(deployer, { MarketDiamond: marketDiamondAccessManagedFacet })

    const authority = await deployerDeployments.MarketDiamond.authority()
    console.log('authority', authority)
    if (authority === ethers.ZeroAddress) {
        await deployerDeployments.MarketDiamond.setAuthority(accessManagerAddress)
        console.log('authority set to', accessManagerAddress)
    } else {
        console.log('WARNING: authority already set to', authority)
    }

}
export default func
func.tags = ['MarketDiamond']
func.dependencies = ['BlexAccessManager']
