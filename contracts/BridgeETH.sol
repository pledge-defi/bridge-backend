// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';

interface IBridge {
    function deposit(uint8 destinationDomainID, bytes32 resourceID, bytes calldata data) external payable;
}

contract PledgerBridgeETH is ERC20Safe {
    using BytesLib for bytes;

    // chainbridge ERC20Handler address.
    address public bridge_address;

    // admin address;
    address public owner;

    // MPLGR ERC20 token address
    address public mplgr_address;

    // Arguments for chainbridge.
    uint8 cb_ddid;
    bytes32 cb_rid;

    // Store mplgr amounts by address.
    mapping(address => uint256) mplgr_amounts;

    event WithdrawMPLGR(address recipient, uint256 amount);

    event DepositMPLGR(address owner, uint256 amount);

    constructor(address _bridge_address, address _mplgr_address, uint8 _cb_ddid, bytes32 _cb_rid) public {
        owner = msg.sender;
        bridge_address = _bridge_address;
        mplgr_address = _mplgr_address;
        cb_ddid = _cb_ddid;
        cb_rid = _cb_rid;
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
    function deposit_mplgr(address _owner, uint256 amount) external {
        lockERC20(mplgr_address, _owner, address(this), amount);

        bytes memory args = abi.encode(_owner, amount);

        IBridge bridge = IBridge(bridge_address);

        bridge.deposit(cb_ddid, cb_rid, args);
    }
}
