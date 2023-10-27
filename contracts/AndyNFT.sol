// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//https://medium.com/pinata/how-to-launch-a-generative-nft-collection-with-ipfs-and-avalanche-146703a8e280

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AndyNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;
  using Counters for Counters.Counter;

  string public baseURI;
  uint256 public MAX_SUPPLY = 1;
  uint public PRICE = 0;

  constructor(
    string memory baseURI,

  )

}