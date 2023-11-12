// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AssemblyVariable {
  function yul_let() public pure returns (uint z) {
    assembly {
      // language used for assembly is Yul
      // local variables
      let x := 123
      z := 456
    }
  }
}