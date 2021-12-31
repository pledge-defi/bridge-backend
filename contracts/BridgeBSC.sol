// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';

interface IBridge {
    function deposit(uint8 destinationDomainID, bytes32 resourceID, bytes calldata data) external payable;
}

contract PledgerBridgeBSC is ERC20Safe {
    using BytesLib for bytes;

    address public owner;

    address public plgr_address;

    address public bridge_address;

    address public handler_address;

    uint256 public wait_time;

    uint256 public release_count = 0;
    uint256 public price = 1;
    uint256 public total_pledge = 0;

    // Arguments for chainbridge.
    uint8 public cb_ddid;
    bytes32 public cb_rid;

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
    mapping (bytes32 => LockedPLGRTx) public can_release;

    LockInfo[] public locked_infos;

    uint256 plgr_lock_nonce = 0;

    event DepositPLGR(bytes32 txid, address owner, uint256 amount, uint time);

    event WithdrawPLGR(address owner, uint256 amount);

    constructor(address _plgr_address, address _bridge_address, address _handler_address, uint8 _cb_ddid, bytes32 _cb_rid) public {
        owner = msg.sender;
        plgr_address = _plgr_address;
        bridge_address = _bridge_address;
        handler_address = _handler_address;
        cb_ddid = _cb_ddid;
        cb_rid = _cb_rid;
    }

    function admin_update_configure(uint256 _wait_time) external {
        require(msg.sender == owner, "Admin only called by owner");

        wait_time = _wait_time;
    }

    function admin_update_bridge(address _bridge_address, address _handler_address, uint8 _cb_ddid, bytes32 _cb_rid) external {
        require(msg.sender == owner, "Admin only called by owner");

        bridge_address = _bridge_address;
        handler_address = _handler_address;
        cb_ddid = _cb_ddid;
        cb_rid = _cb_rid;
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
        total_pledge += amount / 3;
    }

    function get_base(uint256 _count) view public returns(uint256) {
        uint256 base = 0;
        uint256 n = _count / 12 + 1; // 3 months = 12 weeks
        if (n <= 4) { // 1~12 months
            base = n * 100000 * 10 ** 18;
        } else if (n > 4 && n <= 8) { // 12~24 months
            base = 2000000 * 10 ** 18;
        } else if (n > 8 && n <= 12) { // 24~36 months
            base = 4000000 * 10 ** 18;
        } else if (n > 12 && n <= 16) { // 36~48 months
            base = 10000000 * 10 ** 18;
        } else { // 48~ months
            base = 20000000 * 10 ** 18;
        }

        return base;
    }

    function check_upkeep() view public returns (int256) {
        if (locked_infos.length == 0) {
            return -1;
        }

        mapping(bytes32 => uint256) txid_release_amount;
        uint256[] index_txid;
        for(uint i = 0; i != locked_infos.length; i ++) {
            if (locked_infos[i].time + wait_time > now) {
                return int256(i) - 1;
            } else {
                bytes32 txid = locked_infos[i].txid;
                txid_release_amount[txid] = locked_plgr_tx[txid].amount;
                index_txid.push(txid);
            }
        }

        // to do: get price from oracle.
        uint256 x = 0;
        if (price < 1) {
            x = 1;
        } else if (price >= 1 && price <= 125) {
            // to do: x is the cubic root of price.
            x = 1;
        } else {
            x = 5;
        }

        uint256 base = get_base(release_count);
        require(base > 0, "ERROR: base is zero");
        uint256 amount = base * x / 4;

        for (uint i = 0; i< index_txid.length; i++) {
            bytes32 txid = index_txid[i];
            uint256 amount = txid_release_amount[txid] * amount / total_pledge;

            require(locked_plgr_tx[txid].amount >= amount, "ERROR: Insufficient remaining pledge");
            locked_plgr_tx[txid].amount -= amount;

            can_release[txid].owner = locked_plgr_tx[txid].owner;
            can_release[txid] = amount;
        }

        return 0;
    }

    function execute_upkeep(int256 index) external {
        uint256 count = uint256(index) + 1;

        bytes memory rdata = abi.encode(count);
        uint256 total_release = 0;
        if (index >= 0) {
            for (uint i = 0; i <= uint256(index); i ++) {
                bytes32 txid = can_release[i].txid;

                bytes memory addr = abi.encodePacked(can_release[txid].owner);
                rdata = rdata.concat(addr);

                bytes memory amount = abi.encode(can_release[txid].amount);
                rdata = rdata.concat(amount);

                total_release += can_release[txid].amount;

                delete can_release[txid];
                if (locked_plgr_tx[txid].amount < 1*10**15) { // amount < 0.001
                    delete locked_plgr_tx[txid];
                    delete locked_infos[i];
                }
            }

            bytes memory args_bytes = abi.encode(rdata);
            bytes memory length = abi.encode(args_bytes.length);
            bytes memory args = length.concat(args_bytes);
            IBridge bridge = IBridge(bridge_address);
            bridge.deposit(cb_ddid, cb_rid, args);

            release_count += 1;
            total_pledge -= total_release;
        }
    }
}