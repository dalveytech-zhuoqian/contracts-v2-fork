const { Relayer } = require('defender-relay-client');

// Main business logic
/** 
 * 
  它是一个异步函数，以“relayer”对象作为参数。
  在函数内部，它使用“relayer.sendTransaction”方法将资金发送到目标地址。
  交易详细信息包括收件人地址（“to”）、要发送的资金金额（“value”）、交易速度（“speed”）和
  Gas 限制（“gasLimit”）。 
*/
exports.main = async function(relayer) {
  // Send funds to a target address
  const txRes = await relayer.sendTransaction({
    to: '0xc7dd3ff5b387db0130854fe5f141a78586f417c6',
    value: 100,
    speed: 'fast',
    gasLimit: '1000000',
  });

  console.log(`Sent transaction ${txRes.hash}`);
  return txRes.hash;
}

// Entrypoint for the Autotask
exports.handler = async function(credentials) {
  const relayer = new Relayer(credentials);
  return exports.main(relayer);  
}

// To run locally (this code will not be executed in Autotasks)
if (require.main === module) {
  require('dotenv').config();
  const { API_KEY: apiKey, API_SECRET: apiSecret } = process.env;
  exports.handler({ apiKey, apiSecret })
    .then(() => process.exit(0))
    .catch(error => { console.error(error); process.exit(1); });
}