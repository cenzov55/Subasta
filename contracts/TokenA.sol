// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20("TokenA", "TKA") {
    constructor() {
        _mint(msg.sender, 100000);
    }
}