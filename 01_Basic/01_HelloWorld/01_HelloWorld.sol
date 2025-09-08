// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract HelloWorld {
    string public str = "hello world";
}

contract Counter {
    uint public count;

    function inc() external {
        count++;
    }

    function dec() external {
        count--;
    }
}
