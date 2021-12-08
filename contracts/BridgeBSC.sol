// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';

contract PledgerBridgeBSC is ERC20Safe {
    using BytesLib for bytes;

    address public owner;

    address public plgr_address;

    address public bridge_address;

    address public handler_address;

    uint256 public wait_time;

    struct LockedPLGRTx {
        address owner;
        uint256 amount;
    }

    struct LockInfo {
        bytes32 txid;
        uint256 time;
    }

    mapping (address => uint256) public plgr_amounts;

    mapping (bytes32 => LockedPLGRTx) public locked_plgr_tx;

    LockInfo[] public locked_infos;

    uint256 plgr_lock_nonce = 0;

    event DepositPLGR(bytes32 txid, address owner, uint256 amount, uint time);

    event WithdrawPLGR(address owner, uint256 amount);

    constructor(address _plgr_address, address _bridge_address, address _handler_address) public {
        owner = msg.sender;
        plgr_address = _plgr_address;
        bridge_address = _bridge_address;
        handler_address = _handler_address;
    }

    function admin_update_configure(uint256 _wait_time) external {
        require(msg.sender == owner, "Admin only called by owner");

        wait_time = _wait_time;
    }

    function admin_update_bridge(address _bridge_address, address _handler_address) external {
        require(msg.sender == owner, "Admin only called by owner");

        bridge_address = _bridge_address;
        handler_address = _handler_address;
    }

    // User call this function on BSC to deposit PLGR.
    function deposit_plgr(address _owner, uint256 amount) external returns(bytes32) {

        bytes32 txid = keccak256(abi.encode(_owner, amount, now, plgr_lock_nonce));
        plgr_lock_nonce ++;

        locked_plgr_tx[txid].owner = _owner;
        locked_plgr_tx[txid].amount = amount;

        lockERC20(plgr_address, _owner, address(this), amount);

        LockInfo memory lock_info = LockInfo (txid, now);

        locked_infos.push(lock_info);

        emit DepositPLGR(txid, _owner, amount, now);

        return txid;
    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(uint256 amount) external {
        uint256 value = plgr_amounts[msg.sender];

        require(value >= amount, "You have no enough PLGR");

        plgr_amounts[msg.sender]  -= amount;

        releaseERC20(plgr_address, msg.sender, amount);

        emit WithdrawPLGR(msg.sender, amount);
    }

    // Chainbridge call this function on BSC
    function deposit_mplgr_bridge(bytes memory data) external {
        require(msg.sender == handler_address, "This function only by chainbridge");

        address addr = data.toAddress(0);
        uint256 amount = data.toUint256(20);

        plgr_amounts[addr] += amount / 3;
    }

    function check_upkeep() view public returns (int256) {
        for(uint i = 0; i != locked_infos.length; i ++) {
            if (locked_infos[i].time + wait_time > now) {
                return int256(i) - 1;
            }
        }
    }

    function execute_upkeep(int256 index) external returns(bool result, bytes memory data) {
        uint256 count = uint256(index) + 1;

        bytes memory rdata = abi.encode(count);

        if (index < 0) {
            return (false, bytes(""));
        } else {
            for (uint i = 0; i <= uint256(index); i ++) {
                bytes32 txid = locked_infos[i].txid;

                bytes memory addr = abi.encode(locked_plgr_tx[txid].owner);
                rdata = rdata.concat(addr);

                bytes memory amount = abi.encode(locked_plgr_tx[txid].amount);

                rdata = rdata.concat(amount);

                delete locked_plgr_tx[txid];
                delete locked_infos[i];
            }

            return (true, rdata);
        }
    }
}
