// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.0;

import './ERC20Safe.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';

interface IBridge {
    function deposit(uint8 destinationDomainID, bytes32 resourceID, bytes calldata data) external payable;
}

contract PledgerBridgeBSC is ERC20Safe {
    using BytesLib for bytes;

    // 管理员账号地址
    address public owner;

    // [由管理员进行设置]
    // 桥设置相关参数
    address public plgr_address;
    address public bridge_address;
    address public handler_address;
    // ETH bridgeID
    uint8 public cb_ddid; 
    // resourceID
    bytes32 public cb_rid;

    // [由管理员进行设置]
    // 本周期MPLGR的释放总量
    // 默认本周期释放1个MPLGR 
    uint256 public total_mplgr_release = 1 * 10 ** 18; 

    // [由管理员进行设置]
    // 设置要收取的垮桥fee
    // 默认0.05 BNB
    uint256 public bridge_gas_fee = 0.05 * 10 ** 18;
    // 接收bridge gas fee
    mapping(address => uint256) public balances;

    // PLGR 和 MPLGR 的兑换因子
    // PLGR <=> mplgr | 3 <=> 1 
    uint256 public factor = 3; 

    // PLGR的锁定总量
    uint256 public total_plgr_locked;

    struct LockedPLGRTx {
        address owner;
        uint256 amount;
    }
    struct LockInfo {
        bytes32 txid;
        uint256 time;
    }
    LockInfo[] public locked_infos;

    mapping (address => uint256) public plgr_amounts;
    mapping (bytes32 => LockedPLGRTx) public locked_plgr_tx;
    mapping (bytes32 => LockedPLGRTx) public can_release;
    mapping(bytes32 => uint256) txid_release_amount;

    // uint256 plgr_lock_nonce = 0;

    event DepositPLGR(bytes32 txid, address owner, uint256 amount, uint time);
    event WithdrawPLGR(address owner, uint256 amount);

    constructor(address _plgr_address, address _bridge_address, address _handler_address, uint8 _cb_ddid, bytes32 _cb_rid) {
        owner = msg.sender;

        plgr_address = _plgr_address;
        bridge_address = _bridge_address;
        handler_address = _handler_address;
        cb_ddid = _cb_ddid;
        cb_rid = _cb_rid;
    }

    // 管理员方法: 更新Bridge配置
    function admin_update_bridge(address _bridge_address, address _handler_address, uint8 _cb_ddid, bytes32 _cb_rid) external {
        require(msg.sender == owner, "Only called by owner");

        bridge_address = _bridge_address;
        handler_address = _handler_address;
        cb_ddid = _cb_ddid;
        cb_rid = _cb_rid;
    }

    // 管理员方法：设置垮桥的gas fee
    function set_bridge_gas_fee(uint256 _bridge_gas_fee) public {
        require(msg.sender == owner, "Only called by owner");

        bridge_gas_fee = _bridge_gas_fee;    
    }

    // 约定：每周日之前，由管理员设置本周要释放的 MPLGR 总量
    function set_total_release(uint256 _total_mplgr_release) external {
        require(msg.sender == owner, "Only called by owner");
        require(_total_mplgr_release >= 1, "total_mplgr_release is less than 1");

        total_mplgr_release = _total_mplgr_release;
    }

    // User call this function on BSC to deposit PLGR.
    // 接收预存的gas fee
    function deposit_plgr(address _owner, uint256 amount) external payable returns(bytes32) {
        require(msg.value >= bridge_gas_fee, "Bridge gas fee is insufficient");
        balances[owner] += msg.value;

        // bytes32 txid = keccak256(abi.encode(_owner, amount, block.timestamp, plgr_lock_nonce));
        // plgr_lock_nonce ++;

        // 如果当前锁定交易存在，则更新amount
        // 如果当前锁定交易不存在， 则创建新map
        bytes32 txid = keccak256(abi.encode(_owner));
        if (locked_plgr_tx[txid].owner == _owner) {
            // locked_plgr_tx[txid].owner = _owner;

            // Append 当前用户的锁定量 
            uint256 user_current_locked = locked_plgr_tx[txid].amount;
            locked_plgr_tx[txid].amount = user_current_locked + amount;
        } else {
            locked_plgr_tx[txid].owner = _owner;
            locked_plgr_tx[txid].amount = amount;
        }

        lockERC20(plgr_address, _owner, address(this), amount);

        LockInfo memory lock_info = LockInfo (txid, block.timestamp);
        locked_infos.push(lock_info);

        // 更新PLGR总锁定量
        total_plgr_locked += amount;

        emit DepositPLGR(txid, _owner, amount, block.timestamp);

        return txid;
    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(uint256 amount) external {
        uint256 value = plgr_amounts[msg.sender];
        require(value >= amount, "You have no enough PLGR");

        plgr_amounts[msg.sender] -= amount;

        releaseERC20(plgr_address, msg.sender, amount);

        emit WithdrawPLGR(msg.sender, amount);
    }

    // Chainbridge call this function on BSC
    function deposit_mplgr_bridge(bytes memory data) external {
        require(msg.sender == handler_address, "This function only by chainbridge");

        address addr = data.toAddress(0);
        uint256 amount = data.toUint256(20);

        // 同时 MPLGR 跨到 PLGR，需要乘以兑换因子
        plgr_amounts[addr] += amount * factor;
    }

    // 如果 [当前PLGR锁定量] <= [MPLGR 当前总释放量] * factor  => 当前锁定的PLGR数额，全部过桥
    // 如果 [当前锁定的PLGR量] > [MPLGR 当前总释放量] * factor => 则，按照 ( [用户的PLGR锁定量] / [当前PLGR总锁定量]) * [MPLGR 当前总释放量] 进行过桥
    function is_release_all_locked_plgr() public view returns (bool) {
        bool release_all_locked_plgr = true;
        if (total_plgr_locked > total_mplgr_release * factor) {
            release_all_locked_plgr = false;
        }

        return release_all_locked_plgr;
    }

    function execute_upkeep() external {
        require(msg.sender == owner, "Only called by owner");
        require(total_mplgr_release >= 1, "total_mplgr_release is less than 1");
        
        bool release_all_locked_plgr = is_release_all_locked_plgr();

        uint256 count = locked_infos.length;
        for (uint i = 0; i < count; i++) {
            bytes32 txid = locked_infos[i].txid;

            // 当前用户PLGR的锁定量
            uint256 user_plgr_locked = locked_plgr_tx[txid].amount;

            // 用户可以跨过去的PLGR量
            uint256 user_plgr_crossed = release_all_locked_plgr ? user_plgr_locked : (user_plgr_locked / total_plgr_locked) * total_mplgr_release * factor;

            // 跨过去后，可以得到的 MPLGR 量
            uint256 user_mplgr_crossed = user_plgr_crossed / factor;
            
            // 更新用户目前没有跨过去（锁定）的PLGR量，[跨前PLGR锁定量 - 跨过去的PLGR量]
            can_release[txid].owner = locked_plgr_tx[txid].owner;
            can_release[txid].amount = user_mplgr_crossed;

            // update locked_plgr_tx
            locked_plgr_tx[txid].amount = user_plgr_locked - user_plgr_crossed;
        }
        // 同时更新当前PLGR的锁定总量
        total_plgr_locked = release_all_locked_plgr ? 0 : (total_plgr_locked - total_mplgr_release * factor);

        // ABI编码
        bytes memory rdata = abi.encode(count);
        for (uint i = 0; i < count; i ++) {
            bytes32 txid = locked_infos[i].txid;

            bytes memory addr = abi.encodePacked(can_release[txid].owner);
            rdata = rdata.concat(addr);

            bytes memory amount = abi.encode(can_release[txid].amount);
            rdata = rdata.concat(amount);
        }

        // 数据清除
        for (uint i=0; i<count;i++) {
            bytes32 txid = locked_infos[i].txid;

            // 释放MPLGR垮桥数据
            delete can_release[txid];

            // 如果有用户所有的锁定PLGR已经释放完，清理数据
            if (locked_plgr_tx[txid].amount == 0) {
                delete locked_plgr_tx[txid];
                delete locked_infos[i];
            }
        }

        // 数据垮桥
        bytes memory args_bytes = abi.encode(rdata);
        bytes memory length = abi.encode(args_bytes.length);
        bytes memory args = length.concat(args_bytes);
        
        IBridge bridge = IBridge(bridge_address);
        bridge.deposit(cb_ddid, cb_rid, args);
    }
}