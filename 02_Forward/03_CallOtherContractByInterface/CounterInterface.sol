// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Counter {
    uint256 public count;
    string public str = "default";

    function increment() external {
        count++;
    }
}
