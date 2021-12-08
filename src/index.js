
var Web3 = require("web3");

// imports abi
const PledgerBridgeBSC_abi = require('./abi/pledgerBridgeBSC.json');
const ChainBridgeBSC_abi = require('./abi/chainBridgeBSC.json');

// import constants
const constants = require('./constants.js');
const reposten_provider = constants.reposten_provider;
const bsc_provider = constants.bsc_provider;
const PledgerBridgeBSC_address = constants.PledgerBridgeBSC_address;
const resource_id = constants.resource_id;
const ChainBridgeBSC_address = constants.ChainBridgeBSC_address;
const destinationChainID = constants.destinationChainID;

function Init_Web3() {
  var w3 = new Web3();
  w3.setProvider(new Web3.providers.HttpProvider(bsc_provider));
  return w3;
}
var w3 = Init_Web3();

function Init_BSC() {
  const MyContract = new w3.eth.Contract(
        PledgerBridgeBSC_abi, // import the contracts's ABI and use it here
        PledgerBridgeBSC_address,
      );
  return MyContract;
}
var MyContract = Init_BSC();

function Init_Chain() {
  const ChainContract = new w3.eth.Contract(
        ChainBridgeBSC_abi, // import the contracts's ABI and use it here
        ChainBridgeBSC_address,
      );
  return ChainContract;
}
const BridgeBSCContract = Init_Chain();

async function check_upkeep() {
  return MyContract.methods.check_upkeep().call().then(function(ret) {
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
      const account = w3.eth.accounts.privateKeyToAccount('0xd355ce1b91b16a0fc6953cc20ec75e19060487a1a157679819d68595bc1e7ca3');
      w3.eth.accounts.wallet.add(account);
      w3.eth.defaultAccount = account.address;

      MyContract.methods.execute_upkeep(index).send({
          from: account.address,
          gas: 5000000,
        }).then(function (result, data) {
        console.log('result = ', result);
        // call chain bridge bsc
        BridgeBSCContract.methods.deposit(destinationChainID, resource_id, data).call().then(console.log);
      });
    // }  // end if
  // } // end while
}

async function run() {
  await execute_upkeep();
}
run();