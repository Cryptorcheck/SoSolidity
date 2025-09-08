// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 可支付 Payable关键字，赋予合约接收和发送以太的能力
contract Payable {
    // 接收以太（合约部署后，在VALUE处输入Wei，点击执行deposit方法即可自动接收，可接收以太的方法部署后按钮是红色的）
    function deposit() external payable {}

    address payable public owner;

    constructor(address _o) {
        // 转payable修饰
        owner = payable(_o);
    }

    // 查询合约余额
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}

contract Payable2 {
    function sendEth() external payable returns (address, uint) {
        return (msg.sender, msg.value);
    }

    function getBalance() external view returns (uint, uint) {
        // gasleft()当前剩余gas
        return (address(this).balance, gasleft());
    }
}
