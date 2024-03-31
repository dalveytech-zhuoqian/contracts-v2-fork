// SPDX-License-Identifier: AGPL-1.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleERC20 is ERC20 {
    constructor(address to, uint256 amount) ERC20("name", "symbol") {
        _mint(to, amount);
    }
}
