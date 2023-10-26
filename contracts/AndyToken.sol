// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract AndyToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
		uint constant _initial_supply = 10000000000 * (10**18);
    constructor()
        ERC20("AndyToken", "ANDY")
        ERC20Permit("AndyToken")
    {
			_mint(msg.sender, _initial_supply);
		}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}