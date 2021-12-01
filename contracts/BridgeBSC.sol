// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';

contract PledgerBridgeBSC is ERC20Safe {
    address public owner;

    address public plgr_address;

    address public bridge_address;

    struct LockedPLGRTx {
        address owner;
        uint256 amount;
        uint256 time;
    }

    mapping (address => uint256) public plgr_amounts;
    mapping (bytes32 => LockedPLGRTx) public locked_plgr_tx;

    uint256 plgr_lock_nonce = 0;

    event DepositPLGR(bytes32 txid, address owner, uint256 amount, uint time);

    event WithdrawPLGR(address owner, uint256 amount);

    constructor(address _plgr_address, address _bridge_address) public {
        owner = msg.sender;
        plgr_address = _plgr_address;
        bridge_address = _bridge_address;
    }

    // User call this function on BSC to deposit PLGR.
    function deposit_plgr(address _owner, uint256 amount) external returns(bytes32) {

        bytes32 txid = keccak256(abi.encode(_owner, amount, now, plgr_lock_nonce));
        plgr_lock_nonce ++;

        LockedPLGRTx memory locked = locked_plgr_tx[txid];
        locked.owner = _owner;
        locked.amount = amount;
        locked.time = now;

        lockERC20(plgr_address, _owner, address(this), amount);
        locked_plgr_tx[txid] = locked;

        emit DepositPLGR(txid, _owner, amount, now);
    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(uint256 amount) external {
        uint256 value = plgr_amounts[msg.sender];

        require(value >= amount, "You have no enough PLGR");

        plgr_amounts[msg.sender] = value - amount;

        releaseERC20(plgr_address, msg.sender, amount);

        emit WithdrawPLGR(msg.sender, amount);
    }

    // Chainbridge call this function on BSC
    function deposit_mplgr(bytes calldata data) external {
        require(msg.sender == bridge_address, "This function only by chainbridge");

        (address addr, uint256 amount) = abi.decode(data, (address, uint256));

        plgr_amounts[addr] += amount / 3;
    }
}
