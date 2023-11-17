// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
  function transfer(address, uint) external returns (bool);

  function transferFrom(address, address, uint) external returns (bool);
}

contract CrowdFund {
  
}