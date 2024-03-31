import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { parseEther } from 'ethers'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const { deployments, getNamedAccounts } = hre
	const { deploy } = deployments

	const { deployer, accessManagerAdmin } = await getNamedAccounts()
	console.log("deployer", deployer)
	console.log("accessManagerAdmin", accessManagerAdmin)

	await deploy('BlexAccessManager', {
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
	})
}
export default func
func.tags = ['BlexAccessManager']
