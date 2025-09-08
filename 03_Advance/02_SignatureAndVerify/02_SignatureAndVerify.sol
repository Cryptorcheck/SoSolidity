// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 本节内容：solidity中的签名和验证
/*
4个步骤：
1、数据准备message
2、hash数据 hash(message)
3、链下过程：使用私钥对hash进行签名
4、链上合约中，使用hash和签名进行ecrecover(hash(message), signature) == signer
*/

contract VerifySign {
    function verify(
        address _signer,
        string memory _msg,
        bytes memory _signature
    ) external pure returns (bool) {
        bytes32 msgHash = getMsgHash(_msg);
        bytes32 ethSignedMsgHash = getEthSignedMsgHash(msgHash);
        return recover(ethSignedMsgHash, _signature) == _signer;
    }

    function getMsgHash(string memory _msg) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_msg));
    }

    function getEthSignedMsgHash(bytes32 _hash) public pure returns (bytes32) {
        // 由于是在链上进行签名，所以需要对原始hash进行加工，表示在以太坊进行链上签名
        // 实际场景中进行链下签名也是对append字符串"\x19Ethereum Signed Message:\n32"后的hash进行签名
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }

    function recover(
        bytes32 _ethSignedMsgHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_signature);
        return ecrecover(_ethSignedMsgHash, v, r, s);
    }

    function _split(
        bytes memory _signature
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // _signature的长度是bytes32（32字节）的r + bytes32（32字节）的s + uint8（1字节）的v，共65字节
        require(_signature.length == 65, "invalid signature");

        assembly {
            r := mload(add(_signature, 32)) // 取1 - 32字节中的第0字节
            s := mload(add(_signature, 64)) // 取33 - 64字节中的第0字节
            v := byte(0, mload(add(_signature, 96))) // 取65 - 96字节中的第0字节
        }
    }

    /*
    ！！！！测试验证流程：需要用到小狐狸钱包：
    消息发送前hash和签名的流程：
    1、模拟消息发送hash：使用getMsgHash函数，传入消息内容后执行，获得hash
    2、登录小狐狸钱包，并打开控制台，进入钱包个人签名流程：
    （1）在控制台中执行：
        ethereum.enable() // 执行后控制台返回一个promise，其中state为fulfilled表示可运行

        account = "0x0c5F7940F2ad99B63976c6e3F5CEAD3fC2Be9F87" // 使用小狐狸钱包中以太坊的个人账户地址
        msgHash = "$要发送的消息通过getMsgHash函数生成的hash"
        // 使用账户地址+消息hash向钱包发起个人签名请求
        ethereum.request({method: "personal_sign", params:[account, msgHash]})
        // 请求返回的promise中的PromiseResult为签名signatrue

    接收消息后的验证流程：
    1、将msgHash传入getEthSignedMsgHash函数，得到一个表示来自以太坊的签名的hash
    2、将来自以太坊的签名的hash和signatrue传入recover函数，得到一个反解的signer地址
    3、反解的signer地址如果等于用于签名的钱包地址，说明验证通过
    */
}
