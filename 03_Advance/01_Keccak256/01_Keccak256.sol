// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/*
用户A发送消息
计算消息hash：H = hash(message)
用户A私钥对hash签名：signature = Sign(H, private key)
发送消息和签名给用户B

用户B接收消息和签名
使用用户A的公钥对签名进行验证，得到哈希值：H' = Verfify(signature, public key)
将收到的消息进行hash：H'' = hsah(message)
比较 H'' == H'，如果相等表示消息未被篡改并且来自用户A
*/

contract HashTest {
    function hash(
        string memory text,
        uint num,
        address addr
    ) external pure returns (bytes32) {
        // abi.encode返回一个完整的bytes，而abi.encodePacked会进行压缩
        return keccak256(abi.encodePacked(text, num, addr));
    }

    // 对比abi.encode abi.encodePacked
    function encode(
        string memory text1,
        string memory text2
    ) external pure returns (bytes memory) {
        return abi.encode(text1, text2);
    }

    function encodePacked(
        string memory text1,
        string memory text2
    ) external pure returns (bytes memory) {
        return abi.encodePacked(text1, text2);
    }

    // hash冲突
    // 使用abi.encodePacked压缩过的字节码进行hash可能存在hash冲突
    // 比如调用上面encodePacked方法，传入"AAA","BBB"与传入"AA","ABBB"的字节码和hash结果都是一样的
    // 解决hash冲突的两种方式：
    // 方式一：
    // 使用abi.encode
    // 方式二：
    // 在两个动态数据间加一个用于分割的变量，比如：x就是用于分割的变量
    // function collision(string memory text1, uint x, string memory text2) external pure returns (bytes32) {
    //     return keccak256(abi.encodePacked(text1, x, text2));
    // }
    function collision(
        string memory text1,
        string memory text2
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text1, text2));
    }
}
