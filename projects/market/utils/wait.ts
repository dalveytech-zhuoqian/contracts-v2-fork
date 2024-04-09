import { ethers } from 'hardhat'

export async function waitFor<T>(p: Promise<{ wait: () => Promise<T> }>): Promise<T> {
    const tx = await p
    try {
        await ethers.provider.send('evm_mine', []) // speed up on local network
    } catch (e) { }
    return tx.wait()
}