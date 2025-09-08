// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Account1 {
    address public bank;
    address public owner;

    constructor(address _owner) payable {
        bank = msg.sender;
        owner = _owner;
    }
}

contract Factory {
    Account1[] public accounts;

    function createAccount(address _owner) external payable {
        // new Account1{value: 111}(_owner),{value: 111}表示每次调用部署合约时，
        // 传入createAccount的以太必须大于111，但发送到Account1合约中的以太只有111
        // FIXME：疑问：那么剩下的以太到哪里去了？
        Account1 account = new Account1{value: 111}(_owner);
        accounts.push(account);
    }
}
