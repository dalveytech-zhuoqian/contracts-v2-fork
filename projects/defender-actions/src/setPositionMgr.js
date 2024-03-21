const { ethers } = require("ethers")
const { DefenderRelaySigner, DefenderRelayProvider } = require('defender-relay-client/lib/ethers')
const axios = require("axios");


async function readMarketABI() {
    let response = await axios.get(
        `https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/artifacts/contracts/market/Market.sol/Market.json`
    );
    return response.data.abi;
}

//https://github.com/blex-dex/address/blob/arbitrum_42161/MarketRouter.json
async function readMarketRouterABI() {
    let response = await axios.get(
        `https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/MarketRouter.json`
    );
    return response.data.abi;

}



async function readAddress(chainId, signer) {
    if ([42161].includes(chainId)) {
        let commonContract = await axios.get(
            ` https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/arbitrum_42161.json`
        );
        let marketRouterAbi = await readMarketRouterABI();
        let marketRouter = new ethers.Contract(commonContract.data.MarketRouter, marketRouterAbi, signer);
        let markets = await marketRouter.getMarkets();

        return {
            "PositionSubMgr": commonContract.data.PositionSubMgr,
            "Market": [markets]
        }

    } else if ([4002].includes(chainId)) {
        let commonContract = await axios.get(
            ` https://raw.githubusercontent.com/blex-dex/address/fantom_4002/fantom_4002.json`
        );
        let marketRouterAbi = await readMarketRouterABI();
        let marketRouter = new ethers.Contract(commonContract.data.MarketRouter, marketRouterAbi, signer);
        let markets = await marketRouter.getMarkets();


        return {
            "PositionSubMgr": commonContract.data.PositionSubMgr,
            "Market": [markets]
        }

    }
    return {
        "PositionSubMgr": "",
        "Market": [],

    }


}

exports.handler = async function (credentials) {
    // ABI 应该从 https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/artifacts/contracts/market/Market.sol/Market.json 获取
    // 应该有个全局配置链的地方
    // 获取所有地址: https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/arbitrum_42161.json
    // 从上述链接中读取 marketReader 地址
    // 要从 marketReader 中读取所有 market 地址
    // 循环遍历所有的 market, 并设置相关合约地址(subMgr, addMgr, orderMgr), 这些地址来自于 https://raw.githubusercontent.com/blex-dex/address/arbitrum_42161/arbitrum_42161.json
    // 调用 multicall, 替换相关合约地址(subMgr, addMgr, orderMgr)

    // Initialize defender relayer provider and signer
    const provider = new DefenderRelayProvider(credentials);
    const signer = new DefenderRelaySigner(credentials, provider, {
        speed: "fast"
    });
    const chainId = (await provider.getNetwork()).chainId
    let MarketABI = await readMarketABI();
    let addressBook = await readAddress(chainId, signer);
    let txs = new Array();
    for (let index = 0; index < addressBook.Market.length; index++) {
        let market = new ethers.Contract(
            addressBook.Market[index],
            MarketABI,
            signer
        );
        let tx = await market.setPositionMgr(addressBook.PositionSubMgr, false);
        txs.push(tx)
    }
    return txs
}