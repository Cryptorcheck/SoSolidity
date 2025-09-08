// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Function Selector 函数选择器
// 本节内容：
// 当两个合约之间相互调用函数时，solidity编译器是如何确定要调用哪个函数的？

// 1、首先我们先部署Receiver合约中的transfer函数，调用transfer函数配合event事件打印出msg.data，并查看msg.data的组成成分
// 2、在remix中调用transfer函数，传入一个地址0x5B38Da6a701c568545dCfcB03FcB875f56beddC4，传入ammout为任意数字
// 3、我们在控制台中找到log事件，得到了data为0xa9059cbb0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000001
// 4、这个字符串可以分成3个部分：
// （1）0xa9059cbb  // 第一部分是这个函数签名（名称部分）的hash，是一个4个字节的16进hash(16进制每2个字符占1个字节，0xa9059cbb去掉0x后：a9 05 9c bb)
// （2）0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4    // 第二部分是这个函数签名（参数部分）的第一个参数
// （3）0000000000000000000000000000000000000000000000000000000000000001    // 第三部分是这个函数签名（参数部分）的第二个参数
contract Receiver {
    event Log(bytes data, address to, uint256 amount);

    struct Person {
        uint256 age;
        address addr;
        mapping(address => uint) a;
    }

    function transfer(address _to, uint256 _amount) external returns (bytes4) {
        emit Log(msg.data, _to, _amount);
        // msg.sig也是函数的选择器，这方式获取选择器更直接，msg.data中不仅包含了选择器，还有具体入参，需要自己解析出选择器
        return msg.sig;
    }
}

// 5、得到这个函数签名后，接下来尝试自己实现底层对一个函数 -> 函数签名（名称部分）的编码
// 6、部署后调用这个函数，模拟transfer函数，传入transfer(address,uint256)，不能带空格
// 7、查看最后返回的函数签名（名称部分）是否与上面得到的函数签名相同
contract FunctionSelector {
    function getSelector(
        string calldata _funcName
    ) external pure returns (bytes4) {
        // 函数名称transfer(address,uint256)转换为字节数组
        bytes memory funcNameBytes = bytes(_funcName);

        // hash
        bytes32 kfuncNameBytes = keccak256(funcNameBytes);

        // hash后取前4字节返回函数名称签名
        return bytes4(kfuncNameBytes);
    }
}
