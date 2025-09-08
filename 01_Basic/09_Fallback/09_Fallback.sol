// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 回退函数
// 1、当调用合约中一个不存在的函数时，合约中的Fallback函数就会被执行
// 2、直接发送以太：
/**
             Ether(以太发向合约)
                    ｜
            is msg.data empty?
                   /   \
                yes    no
                /        \
 is receive exist?      fallback()
        /  \
     yes    no
    /        \
receive()  fallback()
*/
contract FallbackAndReceive {
    event Log(string msg, address sender, uint val, bytes data);

    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("fallback", msg.sender, msg.value, "");
    }
}
