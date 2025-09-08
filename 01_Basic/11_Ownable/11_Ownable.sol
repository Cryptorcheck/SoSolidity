// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setNewOwner(address _newOwner) external onlyOwner {
        // 不能输入一个全0地址
        require(_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    function onlyOwnerCall() external onlyOwner {}

    function anyoneCall() external {}
}
