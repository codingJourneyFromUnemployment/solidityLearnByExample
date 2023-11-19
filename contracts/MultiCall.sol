// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiCall {
  function multiCall(
    address [] calldata targets,
    bytes [] calldata data
  ) external view returns (bytes[] memory) {
    require(targets.length == data.length, "MultiCall: target length != data length");

    bytes[] memory results = new bytes[](data.length);

    for (uint i; i < targets.length; i++) {
      (bool success, bytes memory result) = targets[i].staticcall(data[i]);
      results[i] = result;
    }

    return results;

  }
}