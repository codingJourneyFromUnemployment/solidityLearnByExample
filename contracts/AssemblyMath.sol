// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AssemblyMath {
  function yul_add(uint x, uint y) public pure returns (uint z) {
    assembly {
      z := add(x, y)
    }
  }

  function yul_mul(uint x, uint y) public pure returns (uint z) {
    assembly {
      switch x
      case 0 { z := 0 }
      default {
        z := mul(x, y)
        if iszero(eq(div(z, x), y)) { 
          revert(0, 0) 
          }
      }
    }
  }

  // Round to nearest multiple of b
  function yul_fixed_pint_round(uint x, uint b) public pure returns (uint z) {
    assembly {
      // b = 100
      // x = 90
      // z = 90/100 * 100 = 0 want z = 100
      // z := mul(div(x, b), b)
      let half := div(b, 2)
      z := add(x, half)
      z := mul(div(z, b), b)
    }
  }
}