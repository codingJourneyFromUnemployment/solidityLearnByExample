// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Variables {
  string public text = "Hello";
  uint public num = 123;

  function doSomething() public {
    //some global variables
    uint timestampt = block.timestamp;
    address sender = msg.sender;
    
  }
}