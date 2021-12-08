
var Web3 = require("web3");
var w3 = new Web3();

var reposten = 'https://ropsten.infura.io/v3/acb534b53d3a47b09d7886064f8e51b6';
w3.setProvider(new Web3.providers.HttpProvider(reposten));

// deposit_mplgr_bridge 方法的测试数据
// addr => amount
// const typesArray = [
//     'uint256',
//     'address',
//     'uint256',
//     'address',
//     'uint256',
// ];
// const eth_addrs = [
//     '2',
// 	'0x21C6606F90E6065F654cd77171b26A21Ec57105c', 
//     '1', // A-Ropsten
// 	'0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028', 
//     '2', // B-Ropsten
// ];

const typesArray = [
    // 'uint256',
    'mapping (address => uint256)',  
];
const eth_addrs = [
    // '2',
	// [['0x21C6606F90E6065F654cd77171b26A21Ec57105c', '1'], ['0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028', '2']],
    ['0x21C6606F90E6065F654cd77171b26A21Ec57105c', '1']
];


function test_data() {
	//encode params
	const hexString = w3.eth.abi.encodeParameters(typesArray, eth_addrs);//['bytes32'], ['0x21C6606F90E6065F654cd77171b26A21Ec57105c']);
	console.log('hexString = ', hexString);

	//decode params
	const y = w3.eth.abi.decodeParameters(typesArray, hexString);
	console.log('y = ', y);
}

function to_bytes(address) {
    return w3.utils.hexToBytes(address)
}

function wrap_data() {
    const count = w3.eth.abi.encodeParameters(['uint256'], ['2']);
    console.log('count = ', count);

    const addr1 = to_bytes('0x21C6606F90E6065F654cd77171b26A21Ec57105c');
    console.log('addr1 = ', addr1);

    const a1 = w3.eth.abi.encodeParameters(['uint256'], ['1']);
    console.log('a1 = ', a1);

    const addr2 = to_bytes('0x6e4f03a24CAec5D18fbA1c1eC78a5e1Ff6146028');
    console.log('addr2 = ', addr2);

    const a2 = w3.eth.abi.encodeParameters(['uint256'], ['2']);
    console.log('a2 = ', a2);
}

wrap_data();