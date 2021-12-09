
var Web3 = require("web3");

// imports abi
const PledgerBridgeBSC_abi = require('./abi/pledgerBridgeBSC.json');

// import constants
const constants = require('./constants.js');
const bsc_provider = constants.bsc_provider;
const PledgerBridgeBSC_address = constants.PledgerBridgeBSC_address;
const resource_id = constants.resource_id;
const privateKey = constants.privateKey;

// init web3js
function Init_Web3() {
  var w3 = new Web3();
  w3.setProvider(new Web3.providers.HttpProvider(bsc_provider));

  const account = w3.eth.accounts.privateKeyToAccount(privateKey);
  w3.eth.accounts.wallet.add(account);
  w3.eth.defaultAccount = account.address;

  return w3;
}

var w3 = Init_Web3();

// init PledgerBridgeBSC
function Init_BSC() {
  const PledgerBridgeBSC = new w3.eth.Contract(
        PledgerBridgeBSC_abi,
        PledgerBridgeBSC_address,
      );
  return PledgerBridgeBSC;
}
var PledgerBridgeBSC = Init_BSC();

// keeper logics
async function check_upkeep() {
  return PledgerBridgeBSC.methods.check_upkeep().call().then(function(ret) {
    console.log('check upkeep result : ', ret);
    return ret;
  });
}

async function execute_upkeep() {
  const index = await check_upkeep();
  // while(true) {
    // if(ret) {
      // console.log('execute upkeep...');
      // execute upkeep
      PledgerBridgeBSC.methods.execute_upkeep(index).send({
          from: w3.eth.defaultAccount,
          gas: 1000000,
        }).then();
    // }  // end if
  // } // end while
}

async function run() {
  await execute_upkeep();
}
run();