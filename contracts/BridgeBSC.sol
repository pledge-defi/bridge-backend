// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.6.12;

import './ERC20Safe.sol';

contract PledgerBridgeBSC is ERC20Safe {
    address public owner;

    address public plgr_address;

    address public bridge_address;

    constructor(address _plgr_address, address _bridge_address) public {
        owner = msg.sender;
        plgr_address = _plgr_address;
        bridge_address = _bridge_address;
    }



    mapping (address => uint256) public plgrAmount;
    mapping (bytes32 => uint256) public lockedPlgrTx;

    event DepositPLGR(address owner, uint256 amount, uint time);

    event WithdrawPLGR(address owner, uint256 amount);

    // User call this function on BSC to deposit PLGR.
    function deposit_plgr(address _owner, uint256 amount) external {
        lockERC20(plgr_address, _owner, address(this), amount);

        // Store user info.

        emit DepositPLGR(_owner, amount, now);
    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(address _owner, uint256 amount) external {
        releaseERC20(plgr_address, _owner, amount);

        // Desc user info.

        emit WithdrawPLGR(_owner, amount);
    }

    // Chainbridge call this function on BSC
    function deposit_mplgr(bytes calldata data) external {
        uint256      lenMetadata;
        bytes memory metadata;

        lenMetadata = abi.decode(data, (uint256));
        metadata = bytes(data[32:32 + lenMetadata]);
    }

    // Keepers service call this funtion to get when and how to pass bridge.
    function checkUpkeep(bytes calldata checkData) public view returns(bool, bytes memory) {
        address wallet = abi.decode(checkData, (address));
        return (wallet.balance < 1 ether, bytes(""));
    }

    // Execute keeper.
    function performUpkeep(bytes calldata performData) external {
        address[] memory wallets = abi.decode(performData, (address[]));
        for (uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(1 ether);
        }
    }
}
