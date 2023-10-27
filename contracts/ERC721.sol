// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC165 {
  function supportsInterface(bytes4 interfaceID) external view returns (bool); 
}

interface IERC721 is IERC165 {
  function balanceOf(address owner) external view returns (uint balance);

  function ownerOf(uint tokenId) external view returns (address owner);

  function safeTransferFrom(
    address from,
    address to,
    uint tokenId,
    bytes calldata data
  ) external;

  function transferFrom(
    address from,
    address to,
    uint tokenId
  ) external;
}

interface IERC721Receiver {
  function onERC721Received(
    address opertator,
    address from,
    uint tokenId,
    bytes calldata data
  ) external returns (bytes4);
}

contract ERC721 is IERC721 {
  event Transfer(address indexed from, address indexed to, uint indexed id);
  event Approval(address indexed owner, address indexed spender, uint indexed id);
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );
  
  // Mapping from token ID to owner address
  mapping(uint => address) internal _ownerOf;
  // Mapping owner address to token count
  mapping(address => uint) internal _balanceOf;
  // Mapping from token ID to approved address
  mapping(uint => address) internal _approvals;
  // Mapping from owner to operator approvals
  mapping(address => mapping(address => bool)) public isAppprovedForAll;

  function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
    return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  function ownerOf(uint id) external view returns (address owner) {
    owner = _ownerOf[id];
    require(owner != address(0), "token does not exist");
  }

  function balanceOf(address owner) external view returns (uint) {
    require(owner != address(0), "owner cannot be zero address");
  }

  function setApprovalForAll(address operator, bool approved) external {
    isAppprovedForAll[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function approve(address spender, uint id) external {
    address owner = _ownerOf[id];
    require(
      msg.sender == owner || isAppprovedForAll[owner][msg.sender],
      "not authorized"
    );
    _approvals[id] = spender;
    emit Approval(owner, spender, id);
  }

  function getApproved(uint id) external view returns (address) {
    require(_ownerOf[id] != address(0), "token does not exist");
    return _approvals[id];
  }

  function _isApprovedOrOwner(
    address owner,
    address spender,
    uint id
  ) internal view returns (bool) {
    return (
      spender == owner ||
      isAppprovedForAll[owner][spender] ||
      spender == _approvals[id]
    );
  }

  function transferFrom(
    address from,
    address to,
    uint id
    ) public {
      require(from == _ownerOf[id], "from != owner");
      require(to != address(0), "transfer to zero address");
      require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

      _balanceOf[from] -= 1;
      _balanceOf[to] += 1;
      _ownerOf[id] = to;

      delete _approvals[id];

      emit Transfer(from, to, id);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint id
  ) external {
    require(
      to.code.length == 0 || 
        IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") == 
        IERC721Receiver.onERC721Received.selector,
      "unsafe recipient"
    );

    transferFrom(from, to, id);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint id,
    bytes calldata data
  ) external {
    require(
      to.code.length == 0 || 
        IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) == 
        IERC721Receiver.onERC721Received.selector,
      "unsafe recipient"
    );

    transferFrom(from, to, id);
  }

  function _mint(address to, uint id) internal {
    require(to != address(0), "mint to zero address");
    require(_ownerOf[id] == address(0), "token already minted");

    _balanceOf[to] += 1;
    _ownerOf[id] = to;

    emit Transfer(address(0), to, id);
  }

  function _burn(uint id) internal {
    address owner = _ownerOf[id];
    require(owner != address(0), "token not minted");

    _balanceOf[owner] -= 1;

    delete _ownerOf[id];  
    delete _approvals[id];

    emit Transfer(owner, address(0), id);
  }
}

contract MyNFT is ERC721 {
  function mint(address to, uint id) external {
    _mint(to, id);
  }

  function burn(uint id) external {
    require(msg.sender == _ownerOf[id], "not owner");
    _burn(id);
  }
}