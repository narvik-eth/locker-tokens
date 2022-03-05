//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FT is ERC20("FT", "Fungible Token") {
    constructor() {
        _mint(msg.sender, 100_000_000_000_000_000_000);
    }
}
