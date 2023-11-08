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

  function getProxyAdmin(address proxy) external view returns (address) {
    (bool ok , bytes memory res) = proxy.staticcall(
      abi.encodeCall(Proxy.admin, ())
      );
    require(ok, "call failed");
    return abi.decode(res, (address));
  }
}