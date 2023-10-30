// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// interface IERC1155 {
//   function  safeTransferFrom(
//     address from,
//     address to,
//     uint256 id,
//     uint256 value,
//     bytes calldata data
//   ) external;
  
//   function safeBatchTransferFrom(
//     address _from,
//     address _to,
//     uint256[] calldata ids,
//     uint256[] calldata values,
//     bytes calldata data
//   ) external;

//   function balanceOf(address owner, uint256 id) external view returns (uint256);

//   function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view returns (uint256[] memory);

//   function setApprovalForAll(address operator, bool approved) external;

//   function isApprovedAll(
//     address _owner,
//     address _operator
//   ) external view returns (bool isOperator);
// }

// contract ERC1155 is IERC1155 {
//   event TransferSingle(
//     address indexed operator,
//     address indexed from,
//     address indexed to,
//     uint256 id,
//     uint256 value
//   );

//   event TransferBatch(
//     address indexed operator,
//     address indexed from,
//     address indexed to,
//     uint256[] ids,
//     uint256[] values
//   );

//   event ApprovalForAll(
//     address indexed account,
//     address indexed operator,
//     bool approved
//   );

//   event URI(string value, uint256 indexed id);

//   //owner => (id => balance)
//   mapping (address => mapping (uint256 => uint256)) public balanceOf;

//   //owner => (operator => approved)
//   mapping (address => mapping (address => bool)) public isApprovedForAll;

//   // Query the balance of a certain token of a user, where the user and token id must correspond one-to-one in two arrays. For example: owners = [address of user 1, address of user 1, address of user 1, address of user 2, address of user 2, address of user 2]; ids = [1, 2, 3, 1, 2, 3]; Return values: [balance of token 1 of user 1, balance of token 2 of user 1, balance of token 3 of user 1, balance of token 1 of user 2, balance of token 2 of user 2, balance of token 3 of user 2].
//   function balanceOfBatch(
//     address[] calldata owners,
//     uint256[] calldata ids
//   ) external view returns (uint256[] memory balances) {
//     require(owners.length == ids.length, "ERC1155: INVALID_ARRAY_LENGTH");

//     balances = new uint256[](owners.length);

//     unchecked {
//       for (uint256 i = 0; i < owners.length; i++) {
//         balances[i] = balanceOf[owners[i]][ids[i]];
//       }
//     }
//   }

//   function setApprovalForAll(
//     address operator,
//     bool approved
//   ) external {
//     isApprovedForAll[msg.sender][operator] = approved;
//     emit ApprovalForAll(msg.sender, operator, approved);
//   }
  
//   function safeTransferFrom(
//         address from,
//         address to,
//         uint256 id,
//         uint256 value,
//         bytes calldata data
//     ) external {
//         require(
//             msg.sender == from || isApprovedForAll[from][msg.sender],
//             "not approved"
//         );
//         require(to != address(0), "to = 0 address");

//         balanceOf[from][id] -= value;
//         balanceOf[to][id] += value;

//         emit TransferSingle(msg.sender, from, to, id, value);

//         if (to.code.length > 0) {
//             require(
//                 IERC1155TokenReceiver(to).onERC1155Received(
//                     msg.sender,
//                     from,
//                     id,
//                     value,
//                     data
//                 ) == IERC1155TokenReceiver.onERC1155Received.selector,
//                 "unsafe transfer"
//             );
//         }
//     }
  
//   function safeBatchTransferFrom(
//         address from,
//         address to,
//         uint256[] calldata ids,
//         uint256[] calldata values,
//         bytes calldata data
//     ) external {
//         require(
//             msg.sender == from || isApprovedForAll[from][msg.sender],
//             "not approved"
//         );
//         require(to != address(0), "to = 0 address");
//         require(ids.length == values.length, "ids length != values length");

//         for (uint256 i = 0; i < ids.length; i++) {
//             balanceOf[from][ids[i]] -= values[i];
//             balanceOf[to][ids[i]] += values[i];
//         }

//         emit TransferBatch(msg.sender, from, to, ids, values);

//         if (to.code.length > 0) {
//             require(
//                 IERC1155TokenReceiver(to).onERC1155BatchReceived(
//                     msg.sender,
//                     from,
//                     ids,
//                     values,
//                     data
//                 ) == IERC1155TokenReceiver.onERC1155BatchReceived.selector,
//                 "unsafe transfer"
//             );
//         }
//     }
  
//   // ERC165
//   function supportsInterface(bytes4 interfaceId) external view returns (bool) {
//       return
//           interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
//           interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
//           interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
//   }

//   // ERC1155 Metadata URI
//   function uri(uint256 id) public view virtual returns (string memory) {}

//   // Internal functions
//   function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
//         require(to != address(0), "to = 0 address");

//         balanceOf[to][id] += value;

//         emit TransferSingle(msg.sender, address(0), to, id, value);

//         if (to.code.length > 0) {
//             require(
//                 IERC1155Receiver(to).onERC1155Received(
//                     msg.sender,
//                     address(0),
//                     id,
//                     value,
//                     data
//                 ) == IERC1155Receiver.onERC1155Received.selector,
//                 "unsafe transfer"
//             );
//         }
//     }

//   function _batchMint(
//     address to,
//     uint256[] calldata ids,
//     uint256[] calldata values,
//     bytes calldata data
//   ) internal {
//     require(to != address(0), "to = 0 address");
//     require(ids.length == values.length, "ids length != values length");

//     for (uint256 i = 0; i < ids.length; i++) {
//       balanceOf[to][ids[i]] += values[i];
//     }

//     emit TransferBatch(msg.sender, address(0), to, ids, values);

//     if(to.code.length > 0) {
//       require(
//         IERC1155Receiver(to).onERC1155BatchReceived(
//           msg.sender,
//           address(0),
//           ids,
//           values,
//           data
//         ) == IERC1155Receiver.onERC1155BatchReceived.selector,
//         "unsafe transfer"
//       );
//     }
//   }

//   function _burn(
//     address from,
//     uint256 id,
//     uint256 value
//   ) internal {
//     require(from != address(0), "from = 0 address");
//     balanceOf[from][id] -= value;

//     emit TransferSingle(msg.sender, from, address(0), id, value);
//   }

//   function _batchBurn(
//     address from,
//     uint[] calldata ids,
//     uint256[] calldata values
//   ) internal {
//     require(from != address(0), "from = 0 address");
//     require(ids.length == values.length, "ids length != values length");

//     for (uint256 i = 0; i < ids.length; i++) {
//       balanceOf[from][ids[i]] -= values[i];
//     }

//     emit TransferBatch(msg.sender, from, address(0), ids, values);
//   }
// }

// contract MyMultitoken is ERC1155 {
//   function mint(uint256 id, uint256 value, bytes memory data) external {
//     _mint(msg.sender, id, value, data);
//   }

//   function batchMint(
//     uint256[] calldata ids,
//     uint256[] calldata values,
//     bytes calldata data
//   ) external {
//     _batchMint(msg.sender, ids, values, data);
//   }

//   function burn(uint256 id, uint256 value) external {
//     _burn(msg.sender, id, value);
//   }

//   function batchBurn(
//     uint256[] calldata ids,
//     uint256[] calldata values
//   ) external {
//     _batchBurn(msg.sender, ids, values);
//   }
  
// }