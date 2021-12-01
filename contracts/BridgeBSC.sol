import './ERC20Safe.sol'

contract PledgerBridgeBSC is ERC20Safe {
    address keeper_owner;
    address plgr;



    mapping (address => uint256) public plgrAmount;
    mapping (bytes32 => uint256) public lockedPlgrTx;

    event DepositPLGR(address owner, uint256 amount, uint time);

    event WithdrawPLGR(address owner, uint256 amount);

    // User call this function on BSC to deposit PLGR.
    function deposit_plgr(address owner, uint256 amount) external {
        lockERC20(plgr, owner, address(this), amount);

        // Store user info.

        emit DepositPLGR(owner, amount, now)
    }

    // User call this function on BSC to widthdraw PLGR.
    function widthdraw_plgr(address owner, uint256 amount) external {
        releaseERC20(plgr, owner, amount);

        // Desc user info.

        emit WithdrawPLGR(owner, amount);
    }

    // Chainbridge call this function on BSC
    function deposit_mplgr(bytes data) external {
        uint256      lenMetadata;
        bytes memory metadata;

        lenMetadata = abi.decode(data, (uint256));
        metadata = bytes(data[32:32 + lenMetadata]);

    }

    // Keepers service call this funtion to get when and how to pass bridge.
    function checkUpkeep(bytes checkData) public view returns(bool, bytes memory) {
        address wallet = abi.decode(checkData, (address));
        return (wallet.balance < 1 ether, bytes(""));
    }

    // Execute keeper.
    function performUpkeep(bytes performData) external {
        address[] memory wallets = abi.decode(performData, (address[]));
        for (uint256 i = 0; i < wallets.length; i++) {
            payable(wallets[i]).transfer(1 ether);
        }
    }
}
