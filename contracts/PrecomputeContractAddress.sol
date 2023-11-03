// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Factory {
  function getCreate2Address(
    bytes32 _salt,
    bytes memory _initCode,
    address _factoryAddress
  ) public pure returns (address) {
    bytes32 hash = keccak256(
      abi.encodePacked(
        bytes1(0xff),
        _factoryAddress,
        _salt,
        keccak256(_initCode)
      )
    );
    return address(uint160(uint256(hash) >> (12 * 8)));
  }

  function deploy(
    address _owner,
    uint _foo,
    bytes32 _salt
  ) public payable returns (address) {
    return address(new TestContract{salt: _salt}(_owner, _foo));
  }
}

contract TestContract {
  address public owner;
  uint public foo;

  constructor(address _owner, uint _foo) {
    owner = _owner;
    foo = _foo;
  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
}