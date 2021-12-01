// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';

contract PledgerBridgeETH is ERC20Safe {
    using BytesLib for bytes;

    // chainbridge ERC20Handler address.
    address public bridge_address;

    // admin address;
    address public owner;

    // MPLGR ERC20 token address
    address public mplgr_address;
    
    // Store mplgr amounts by address.
    mapping(address => uint256) mplgr_amounts;

    event WithdrawMPLGR(address recipient, uint256 amount);

    constructor(address _bridge_address, address _mplgr_address) public {
        owner = msg.sender;
        bridge_address = _bridge_address;
        mplgr_address = _mplgr_address;
    }

    // Chainbridge call this function on ETH
    function deposit_mplgr_bridge(bytes calldata data) external {
        require(msg.sender == bridge_address, "widthdraw_mplgr only called by bridge");

        uint256 amountCount;
        bytes memory mplgr_amounts_bytes;

        amountCount = abi.decode(data, (uint256));
        mplgr_amounts_bytes = bytes(data[32:32 + amountCount * ( 20 + 32) ]);

        address addr;
        uint256 amount;

        uint offset_begin = 0;
        uint offset_middle = 20;

        for (uint i = 0; i != amountCount; i ++) {
            offset_begin = i * (20 + 32);
            offset_middle = (i + 1) * 20;

            addr = mplgr_amounts_bytes.toAddress(offset_begin);
            amount = mplgr_amounts_bytes.toUint256(offset_middle);

            mplgr_amounts[addr] = amount;
        }
    }

    // User call this function on ETH to widthdraw MPLGR.
    function widthdraw_mplgr(uint256 amount) external {
        uint256 value = mplgr_amounts[msg.sender];

        require(value >= amount, "You have no enough MPLGR");

        mplgr_amounts[msg.sender] = value - amount;

        releaseERC20(mplgr_address, msg.sender, amount);

        emit WithdrawMPLGR(msg.sender, amount);
    }

    // Call bridge
    // function deposit_mplgr(uint256 amount) external {}
}
