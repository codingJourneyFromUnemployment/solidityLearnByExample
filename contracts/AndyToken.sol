// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";

contract AndyToken is ERC20 {
  uint constant _initial_supply = 100000000000 * (10**18);
  constructor() ERC20 ("AndyToken", "ANDY") {
    mint(msg.sender, _initial_supply);
  }
}