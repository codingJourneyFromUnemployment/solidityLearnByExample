// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1155 {
  function  safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external;
  
  function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external;

  function balanceOf(address owner, uint256 id) external view returns (uint256);

  function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view returns (uint256[] memory);

  function setApprovalForAll(address operator, bool approved) external;

  function isApprovedAll(
    address _owner,
    address _operator
  ) external view returns (bool isOperator);
}

contract ERC1155 is IERC1155 {
  event TransferSingle(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 id,
    uint256 value
  );

  event TransferBatch(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256[] ids,
    uint256[] values
  );

  event ApprovalForAll(
    address indexed account,
    address indexed operator,
    bool approved
  );

  event URI(string value, uint256 indexed id);

  //owner => (id => balance)
  mapping (address => mapping (uint256 => uint256)) public balanceOf;

  //owner => (operator => approved)
  mapping (address => mapping (address => bool)) public isApprovedForAll;

  // Query the balance of a certain token of a user, where the user and token id must correspond one-to-one in two arrays. For example: owners = [address of user 1, address of user 1, address of user 1, address of user 2, address of user 2, address of user 2]; ids = [1, 2, 3, 1, 2, 3]; Return values: [balance of token 1 of user 1, balance of token 2 of user 1, balance of token 3 of user 1, balance of token 1 of user 2, balance of token 2 of user 2, balance of token 3 of user 2].
  function balanceOfBatch(
    address[] calldata owners,
    uint256[] calldata ids
  ) external view returns (uint256[] memory balances) {
    require(owners.length == ids.length, "ERC1155: INVALID_ARRAY_LENGTH");

    balances = new uint256[](owners.length);

    unchecked {
      for (uint256 i = 0; i < owners.length; i++) {
        balances[i] = balanceOf[owners[i]][ids[i]];
      }
    }
  }

  function setApprovalForAll(
    address operator,
    bool approved
  ) external {
    isApprovedForAll[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }
  
}