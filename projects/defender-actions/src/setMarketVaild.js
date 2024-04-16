const { ethers } = require('ethers');
const { DefenderRelaySigner, DefenderRelayProvider } = require('defender-relay-client/lib/ethers');
const axios = require('axios');
const { waitTx } = require('./utils');

const HOST = 'https://raw.githubusercontent.com/blex-dex/address';

const CHAIN_ID_MAP = {
  4002: 'fantom_4002',
  80001: 'mumbai_80001',
  42161: 'arbitrum_42161',
};

async function readMarketABI() {
  let response = await axios.get(`${HOST}/arbitrum_42161/artifacts/contracts/market/Market.sol/Market.json`);
  return response.data.abi;
}

//https://github.com/blex-dex/address/blob/arbitrum_42161/MarketRouter.json
async function readMarketRouterABI() {
  let response = await axios.get(`${HOST}/arbitrum_42161/MarketRouter.json`);
  return response.data.abi;
}

async function readMarketReaderABI() {
  let response = await axios.get(`${HOST}/arbitrum_42161/MarketReader.json`);
  return response.data.abi;
}

async function readAddress(chainId, signer) {
  let marketVailds = new Array();
  let markets = new Array();

  let commonContract = await axios.get(`${HOST}/${CHAIN_ID_MAP[chainId]}/${CHAIN_ID_MAP[chainId]}.json`);

  let marketReaderABI = await readMarketReaderABI();
  let marketReader = new ethers.Contract(commonContract.data.MarketReader, marketReaderABI, signer);
  let allMarket = await marketReader.getMarkets();

  for (let index = 0; index < allMarket.length; index++) {
    let marketName = allMarket[index][0].split('/', 1)[0];
    let market = allMarket[index][1];
    let fantomMarket = await axios.get(`${HOST}/${CHAIN_ID_MAP[chainId]}/${CHAIN_ID_MAP[chainId]}-${marketName}.json`);

    markets.push(market);
    marketVailds.push(fantomMarket.data.MarketValid);
  }
  return {
    Markets: markets,
    MarketVailds: marketVailds,
    PositionSubMgr: commonContract.data.PositionSubMgr,
  };
}

exports.handler = async function (credentials) {
  // Initialize defender relayer provider and signer
  const provider = new DefenderRelayProvider(credentials);
  const signer = new DefenderRelaySigner(credentials, provider, {
    speed: 'fast',
  });
  const chainId = (await provider.getNetwork()).chainId;
  let MarketABI = await readMarketABI();
  let addressBook = await readAddress(chainId, signer);
  let txs = new Array();
  for (let index = 0; index < addressBook.Markets.length; index++) {
    let market = new ethers.Contract(addressBook.Markets[index], MarketABI, signer);
    console.log(addressBook.MarketVailds[index]);
    console.log(addressBook.PositionSubMgr);
    await waitTx(
      market.setMarketValid(addressBook.MarketVailds[index], {
        gasLimit: '2000000',
      }),
    );

    await waitTx(
      market.setPositionMgr(addressBook.PositionSubMgr, false, {
        gasLimit: '2000000',
      }),
    );
  }
  // console.log(txs)
  // return txs;
};

if (require.main === module) {
  require('dotenv').config();
  const { API_KEY: apiKey, API_SECRET: apiSecret } = process.env;
  exports
    .handler({ apiKey, apiSecret })
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}
