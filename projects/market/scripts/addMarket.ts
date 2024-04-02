
import { getNamedAccounts, ethers } from 'hardhat'
import { MarketFacet } from '../typechain-types'
async function waitFor<T>(p: Promise<{ wait: () => Promise<T> }>): Promise<T> {
    const tx = await p
    try {
        await ethers.provider.send('evm_mine', []) // speed up on local network
    } catch (e) { }
    return tx.wait()
}

async function main() {
    const MarketFacet = await ethers.getContract<MarketFacet>('MarketDiamond')
    const { deployer } = await getNamedAccounts()
    const deployerSigner = await ethers.getSigner(deployer)
    await waitFor(MarketFacet.connect(deployerSigner).addMarket("")) // todo
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
