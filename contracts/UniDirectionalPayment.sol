// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract UniDirectionalPaymentChannel is ReentrancyGuard {
  using ECDSA for bytes32;

  address payable public sender;
  address payable public receiver;

  uint private constant DURATION = 7 * 24 * 60 * 60;
  uint public expiresAt;

  constructor(address payable _receiver) payable {
    require(_receiver != address(0), "receiver is the zero address");
    sender = payable(msg.sender);
    receiver = _receiver;
    expiresAt = block.timestamp + DURATION;
  }

  function _getHash(uint _amount) private view returns (bytes32){
    return keccak256(abi.encodePacked(address(this), _amount));
  }

  function _getEthSignedHash(uint _amount) external view returns (bytes32){
    return _getHash(_amount).toEthSignedMessageHash();
  }
}

