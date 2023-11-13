// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Proxy {
  event Deploy(address);

  receive() external payable {}

  function deploy(bytes memory _code) external payable returns (address addr){
    assembly {
      //create(v, p, n)
      //v = amount of eth to send
      //p = pointer in memory to start of code
      //n = length of code
      addr := create(callvalue(), add(_code, 0x20), mload(_code))
      //callvalue() will return the amount of eth sent with the transaction
      //add() 是在把 _code（一个指向字节码的内存指针）和 0x20（32字节，即256位）相加。在Solidity中，动态大小的数据（如bytes）在内存中的布局是：前32字节存储数据的长度，实际数据紧随其后。
      // mload() will load the length of code to memory
    }
    //return address 0 on error
    require(addr != address(0), "Error deploying contract");

    emit Deploy(addr);
  }

  function execute(address _target, bytes memory _data) external payable {
    (bool success,) = _target.call{value: msg.value}(_data);
    require(success, "Error executing contract");
  }
}

contract TestContract1 {
  address public owner = msg.sender;

  function setOwner(address _owner) public {
    require(msg.sender == owner, "Only owner can set owner");
    owner = _owner;
  }
}

contract TestContract2 {
  address public owner = msg.sender;
  uint public value = msg.value;
  uint public x;
  uint public y;

  constructor(uint _x, uint _y) payable {
    x = _x;
    y = _y;
  }
}

contract Helper {
  function getBytecode1() external pure returns (bytes memory) {
    bytes memory bytecode = type(TestContract2).creationCode;
    return bytecode;
  }

  function getBytecode2(uint _x, uint _y) external pure returns (bytes memory) {
    bytes memory bytecode = type(TestContract2).creationCode;
    return abi.encodePacked(bytecode, abi.encode(_x, _y));
  }

  function getCalldata(address _owner) external pure returns (bytes memory) {
    return abi.encodeWithSignature("setOwner(address)", _owner);
  }
}