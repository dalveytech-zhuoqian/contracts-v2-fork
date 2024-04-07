import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction, DeploymentsExtension } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'
import { MarketDiamond } from '../typechain-types'
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

async function setAccessManagerAddress(deployments: DeploymentsExtension, deployer: string): Promise<void> {

    // set AccessManager address in MarketDiamond
    const accessManagerAddress = (await deployments.get('BlexAccessManager')).address
    const marketDiamond = await ethers.getContract<MarketDiamond>('MarketDiamond')
    const deployerDeployments = await setupUser(deployer, { MarketDiamond: marketDiamond })
    const authority = await deployerDeployments.MarketDiamond.authority()
    if (authority === ethers.ZeroAddress) {
        await waitFor(deployerDeployments.MarketDiamond.setAuthority(accessManagerAddress))
        console.log('authority set to', accessManagerAddress)
    } else {
        console.log('WARNING: authority already set to', authority)
    }

}

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre
    const { diamond } = deployments
    const { deployer, accessManagerAdmin } = await getNamedAccounts()
    const MarketDiamondDeployment = await diamond.deploy('MarketDiamond', {
        from: deployer,
        facets: [
            "AccessManagedFacet",
            "DiamondEtherscanFacet",
            "FeeFacet",
            "MarketMakerFacet",
            "MarketFacet",
            "MultiCallFacet",
            "OracleFacet",
            "OrderFacet",
            "PositionAddFacet",
            "PositionFacet",
            "PositionSubFacet",
            "ReferralFacet",
        ], // will prepend TestDiamond_facet_ to each facet name
        log: true,
        autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
    })
    await setAccessManagerAddress(deployments, deployer)

    // const accessManagerAdminDeployments = await setupUser(accessManagerAdmin, { MarketDiamond: marketDiamondAccessManagedFacet })
    // todo: set functions
    // const BlexAccessManager = await ethers.getContract<BlexAccessManager>('BlexAccessManager')
    // const accessManagerAdminSigner = await ethers.getSigner(accessManagerAdmin)
    // await BlexAccessManager.connect(accessManagerAdminSigner).setTargetFunctionRole(
    //     (await deployments.get('MarketDiamond')).address,
    //     [],
    //     1
    // )

}
export default func
func.tags = ['MarketDiamond']
func.dependencies = ['BlexAccessManager']
func.dependencies = ['Vault']
