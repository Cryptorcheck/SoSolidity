// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/// Delegatecall 委托调用、代理调用
/// 常规调用逻辑：
/// A 调用(call) B，发送100wei手续费
/// B 再调用(call) C，发送50wei手续费
/// 对C合约来说，msg.sender是B合约，msg.value是50wei，执行代码读取和操作C的状态变量
///
/// 代理调用逻辑：
/// A 调用(call) B，发送100wei手续费
/// B 代理调用(delegatecall) C
/// 对C合约来说，msg.sender是A合约，msg.value是100wei，执行代码读取和操作B的状态变量

/// 模拟B和C
/// B使用代理调用C，B必须和C的状态变量类型和顺序保持一致
/// 代码逻辑在C合约中，B使用代理调用C后，C的状态变量不会发生改变，改变的是B的状态变量
contract C {
    uint256 num;
    uint256 value;
    address sender;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract B {
    uint256 num;
    uint256 value;
    address sender;

    function setVars(address _execContract, uint256 _num) public payable {
        // delegatecall方式一：类似call
        // (bool ok,) = _execContract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));

        // 方式二：
        (bool ok, ) = _execContract.delegatecall(
            abi.encodeWithSelector(C.setVars.selector, _num)
        );

        require(ok, "delegate call fail");
    }
}
