// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//https://medium.com/pinata/how-to-launch-a-generative-nft-collection-with-ipfs-and-avalanche-146703a8e280

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";

contract AndyNFT is ERC721Enumerable, Ownable, PullPayment {
  using Strings for uint256;
  using Counters for Counters.Counter;

  string public BASE_URI;
  uint256 public MAX_SUPPLY = 1;
  uint public PRICE = 0;

  constructor(
    string memory baseURI,
    uint256 price,
    string memory name,
    string memory symbol
  ) ERC721 (name, symbol){
    PRICE = price;
    BASE_URI = baseURI;
  }

  function _baseURI() internal view override returns (string memory) {
    return string(abi.encodePacked(BASE_URI, "/"));
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    string memory baseURI = _baseURI();
    return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
  }

  function mint(address addr) public payable returns (uint256){
    uint256 supply = totalSupply();
    require(supply < MAX_SUPPLY, "Sale has already ended");
    require(msg.value >= PRICE, "Ether value sent is not correct");
    uint256 tokenId = supply + 1;
    _safeMint(addr, tokenId);

    return tokenId;
  }
}

