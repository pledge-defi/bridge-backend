// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "../3rd_party/chainbridge-solidity/contracts/handlers/GenericHandler.sol";
import "solidity-bytes-utils/contracts/BytesLib.sol";

contract Testing {
    using BytesLib for bytes;
    address public contract_addr;

    function depoly() external returns (address) {
        address myself = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        bytes32 rid = 0x000000000000000000000000000000c76ebe4a02bbc34786d860b355f5a5ce10;
        address caddr = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;
        bytes4 func = 0x02c0ab3b;

        GenericHandler contractt = new GenericHandler(myself,
            rid,
            caddr,
            func,
            func);
        
        contract_addr = address(contractt);
    }

    function generate_data(address _owner, uint256 amount) view public returns(bytes memory) {
        bytes memory amount_bytes = abi.encode(amount);

        bytes memory addr_bytes = abi.encodePacked(_owner);

        bytes memory args_bytes = abi.encode(addr_bytes.concat(amount_bytes));

        // bytes memory length = abi.encode(args_bytes.length);

        // bytes memory args = length.concat(args_bytes);

        return args_bytes;
    }
}
