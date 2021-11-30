contract PledgerBridgeBSC {
    address keeper_owner;

    // User call this function on BSC to deposit PLGR.
    function deposit_plgr(bytes calldata data) external {

    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(bytes calldata data) external {

    }

    // Chainbridge call this function on BSC
    function deposit_mplgr(bytes calldata data) external {

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
