// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Erc20Interface.sol";

contract ERC20 is IERC20Interface {
  uint public totalSupply;
  mapping(address => uint) public balanceOf;
  mapping(address => mapping(address => uint)) public allowance;
  string public name = "AndyToken";
  string public symbol = "ANDY";
  uint8 public decimals = 18;

  function transfer(address recipient, uint amount) public returns (bool) {
    balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint amount) public returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint amount
  ) public returns (bool) {
    allowance[sender][msg.sender] = allowance[sender][msg.sender] - amount;
    balanceOf[sender] = balanceOf[sender] - amount;
    balanceOf[recipient] = balanceOf[recipient] + amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function mint(uint amount) public {
    balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
    totalSupply = totalSupply + amount;
    emit Transfer(address(0), msg.sender, amount);
  }

  function burn(uint amount) public {
    balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
    totalSupply = totalSupply - amount;
    emit Transfer(msg.sender, address(0), amount);
  }
}
