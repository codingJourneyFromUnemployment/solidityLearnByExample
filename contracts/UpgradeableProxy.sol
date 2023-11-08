// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Transparent upgradeable proxy pattern

contract CounterV1 {
  uint public count;

  function inc() external {
    count++;
  }
}

contract CounterV2 {
  uint public count;

  function inc() external {
    count += 1;
  }

  function dec() external {
    count -= 1;
  }
}

contract BuggyProxy {
  address public implementation;
  address public admin;

  constructor() {
    admin = msg.sender;
  }

  function _delegate() private {
    (bool ok, ) = implementation.delegatecall(msg.data);
    require(ok, "delegation failed");
  }

  fallback() external payable {
    _delegate();
  }

  receive() external payable {
    _delegate();
  }

  function upgradeTo(address _implementation) external {
    require(msg.sender == admin, "not authorized");
    implementation = _implementation;
  }
}

contract Dev {
  function selectors() external view returns (bytes4, bytes4, bytes4) {
    return(
      Proxy.admin.selector,
      Proxy.implementation.selector,
      Proxy.upgradeTo.selector
    );
  }
}

contract Proxy {
  //all functions / variables should be private, forward all calls to fallback
  // -1 for unknown preimage
  // 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc

  bytes32 private constant IMPLEMENTATION_SLOT = bytes32 (
    uint(keccak256('eip1967.proxy.implementation')) - 1
  );

  // 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
  bytes32 private constant ADMIN_SLOT = bytes32 (
    uint(keccak256('eip1967.proxy.admin')) - 1
  );
  
  constructor(){
    _setAdmin(msg.sender);
  }

  modifier ifAdmin() {
    if (msg.sender == _getAdmin()) {
      _;
    } else {
      _fallback();
    }
  }

  function _getAdmin() private view returns (address) {
    return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
  }

  function _setAdmin(address _admin) private {
    require(_admin != address(0), "admin is zero");
    StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
  }

  function _getImplementation() private view returns (address) {
    return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
  } 

  function _setImplementation(address _implementation) private {
    StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
  }

  // Admin interface //
  function changeAdmin(address _admin) external ifAdmin {
    _setAdmin(_admin);
  }

  // 0x3659cfe6
  function upgradeTo (address _implementation) external ifAdmin {
    _setImplementation(_implementation);
  }

  // 0xf851a440
  function admin() external ifAdmin returns (address) {
    return _getAdmin();
  }

  // 0x5c60da1b
  function implementation() external view returns (address) {
    return _getImplementation();
  }

  // User interface//
  function _delegate(address _implementation) internal virtual {
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 {revert(0, returndatasize())}
      default {return (0, returndatasize())}
    }
  }

  function _fallback() private {
    _delegate(_getImplementation());
  }

  fallback() external payable {
    _fallback();
  }

  receive() external payable {
    _fallback();
  }
}

contract ProxyAdmin {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  modifier  onlyOwner() {
    require(msg.sender == owner, "not owner");
    _;
  }

  // 在使用低级函数如.call、.delegatecall或.staticcall进行外部合约函数调用时，返回的数据是原始字节格式。这意味着数据并没有直接映射到Solidity的类型系统，而是以字节串的形式存在，这就是变量res的类型是bytes memory的原因。

  // res变量包含了调用的目标函数返回的所有信息，但为了在Solidity中使用这些信息，它们需要被转换为明确的数据类型。这就是abi.decode函数的用途所在。

  // abi.decode函数接收两个参数：

  // 第一个参数是要解码的数据（在这种情况下是res）。
  // 第二个参数是一个类型元组，它告诉解码器期望的返回数据的类型（在这种情况下是(address)，因为我们期望返回一个地址）。
  // 当你调用Proxy.admin函数时，它会返回一个地址类型的数据。这个地址数据被编码为字节串返回。为了将这个字节串转换回地址类型，以便在Solidity中使用，你需要使用abi.decode来解码它。解码操作根据你提供的期望类型正确地解释原始字节数据。

  // 因此，abi.decode(res, (address))的作用是将原始字节格式的返回数据res解码为Solidity的地址类型，这样就可以返回一个Solidity可识别和使用的地址值了。这是处理低级函数调用返回数据的标准方法。

  function getProxyAdmin(address proxy) external view returns (address) {
    (bool ok , bytes memory res) = proxy.staticcall(
      abi.encodeCall(Proxy.admin, ())
      );
    require(ok, "call failed");
    return abi.decode(res, (address));
  }

  function getProxyImplementation(address proxy) external view returns (address) {
    (bool ok , bytes memory res) = proxy.staticcall(
      abi.encodeCall(Proxy.implementation, ())
      );
    require(ok, "call failed");
    return abi.decode(res, (address));
  }

  function changeProxyAdmin(address payable proxy, address admin) external onlyOwner {
    Proxy(proxy).changeAdmin(admin);
  }

  function upgrade(address payable proxy, address implementation) external onlyOwner {
    Proxy(proxy).upgradeTo(implementation);
  }
}

library StorageSlot {
  struct AddressSlot {
    address value;
  }

  function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
    assembly {
      r.slot := slot
    }
  }
} 

contract TestSlot {
  bytes32 public constant slot = keccak256("TEST_SLOT");

  function getSlot() external view returns (address) {
    return StorageSlot.getAddressSlot(slot).value;
  }

  function writeSlot(address _addr) external {
    StorageSlot.getAddressSlot(slot).value = _addr;
  }
}