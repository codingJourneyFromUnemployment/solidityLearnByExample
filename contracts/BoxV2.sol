// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BoxV2 {
    uint256 private value;
		uint256 private result;

    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);
		event ResultChanged(uint256 newResult);

    // Stores a new value in the contract
    function store(uint256 _value) public {
        value = _value;
        emit ValueChanged(_value);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }

		function retrieveResult() public view returns (uint256) {
			return result;
		}

    // Increments the stored value by 1
    function increment() public {
        value = value + 1;
				result = value;
				emit ResultChanged(result);
    }
}
