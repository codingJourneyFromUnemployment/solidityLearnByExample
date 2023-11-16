// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BiDirectionalPaymentChannel {
  using ECDSA for bytes32;

  event ChallengeExit(address indexed sender, uint nonce);
  event Withdraw(address indexed to, uint amount);

  address payable[2] public users;
  mapping (address => bool) public isUser;

  mapping (address => uint) public balances;

  uint public challengePeriod;
  uint public expiresAt;
  uint public nonce;

  modifier checkBalances(uint[2] memory _balances) {
    require(
      address(this).balance >= _balances[0] + _balances[1],
      "ballance of  cocntract must be greater than sum of balances"
    );
    _;
  }

  //Note: deposit from multi-sig wallet
  constructor(
    address payable[2] memory _users,  
    uint[2] memory _balances,
    uint _expiresAt,
    uint _challengePeriod
  ) payable checkBalances(_balances) {
    require(_expiresAt > block.timestamp, "Expiration must be greater than now");
    require(_challengePeriod > 0, "Challenge period must be greater than 0");

    for(uint i = 0; i < _users.length; i++) {
      address payable user = _users[i];

      require(!isUser[user], "user must be unique");
      users[i] = user;
      isUser[user] = true;

      balances[user] = _balances[i];
    }

    expiresAt = _expiresAt;
    challengePeriod = _challengePeriod;
  }

  function verify(
    bytes[2] memory _signatures,
    address _contract,
    address[2] memory _signers,
    uint[2] memory _balances,
    uint _nonce
  ) public pure returns (bool) {
    for (uint i = 0; i < _signatures.length; i++) {
      //Note: sign with address of this contract to protect from replay attack
      bool valid = _signers[i] == keccak256(abi.encodePacked(_contract, _balances, _nonce)).toEthSignedMessageHash().recover(_signatures[i]);

      if(!valid) {
        return false;
      }
    }
    return true;
  }

  modifier checkSignatures(
    bytes[2] memory _signatures,
    uint[2] memory _balances,
    uint _nonce
  ) {
    //Note: copy storage array to memory
    address[2] memory signers;
    for(uint i = 0; i < users.length; i++) {
      signers[i] = users[i];
    }

    require(
      verify(_signatures, address(this), signers, _balances, _nonce),
      "invalid signatures"
    );

    _;
  }

  modifier onlyUser() {
    require(isUser[msg.sender], "caller is not the user");
    _;
  }

  function chanllengeExit(
    uint[2] memory _balances,
    uint _nonce,
    bytes[2] memory _signatures
  ) 
    public 
    onlyUser 
    checkSignatures(_signatures, _balances, _nonce)
    checkBalances(_balances) {
      require(block.timestamp < expiresAt, "channel is expired");
      require(_nonce > nonce, "nonce must be greater than current nonce");

      for (uint i = 0; i < _balances.length; i++) {
        balances[users[i]] = _balances[i];
      }

      nonce = _nonce;
      expiresAt = block.timestamp + challengePeriod;
      emit ChallengeExit(msg.sender, _nonce);
    }

    function withdraw() public onlyUser {
      require(block.timestamp >= expiresAt, "challenge period has not expired");

      uint amount = balances[msg.sender];
      balances[msg.sender] = 0;

      (bool sent, ) = msg.sender.call{value: amount}("");
      require(sent, "Failed to send Ether");

      emit Withdraw(msg.sender, amount);
    }
}