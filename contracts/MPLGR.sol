// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MPLGR is ERC20 {
    constructor(uint256 initialSupply) ERC20("MPLGR", "MPLGR") public {
        _mint(msg.sender, initialSupply);
    }
}
