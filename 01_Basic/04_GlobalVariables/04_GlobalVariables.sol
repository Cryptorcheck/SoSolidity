// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract GlobalVariables {
    function globalVars()
        external
        payable
        returns (
            address sender,
            uint value,
            bytes memory data,
            bytes4 sig,
            uint timestamp,
            uint blockNum,
            uint chainId,
            address origin,
            uint gasprice
        )
    {
        // msg.sender 调用者的地址，全局变量
        sender = msg.sender;
        // 调用合约时发送的eth
        value = msg.value;
        // 交易调用时的完整数据，包括函数选择器和参数
        data = msg.data;
        // 函数选择器，data的钱4字节
        sig = msg.sig;
        // block.timestamp 调用时的unix时间戳
        timestamp = block.timestamp;
        // block.number 该区块块高
        blockNum = block.number;
        // block.chainid
        chainId = block.chainid;
        // 交易发起者
        // 如果没有中间合约，tx.origin与msg.sender是同一个地址
        // 如果有中间合约，tx.origin始终是交易发起者，而msg.sender将会变成中间合约的地址
        // 为了防止中间钓鱼合约攻击安全漏洞，应避免用于身份验证
        origin = tx.origin;
        // 交易的gas价格-uint
        gasprice = tx.gasprice;

        return (
            sender,
            value,
            data,
            sig,
            timestamp,
            blockNum,
            chainId,
            origin,
            gasprice
        );
    }
}
