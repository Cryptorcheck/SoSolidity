// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 函数
contract FunctionIntro {
    function sum(uint a, uint b) external pure returns (uint result) {
        result = a + b;
        return result;
    }

    function sub(uint a, uint b) external pure returns (int result) {
        result = int(a) - int(b);
        return result;
    }
}

// 构造函数
contract Constructor {
    address public owner;
    uint public x;

    constructor(uint _x) {
        owner = msg.sender;
        x = _x;
    }
}

// 函数输出
// Return multiple outputs 返回多输出
// Named outputs 输出命名
// Destructuring Assignment 解构赋值
contract FunctionOutpts {
    function returnMulti() public pure returns (uint, bool) {
        return (1, true);
    }

    function returnNamed() public pure returns (uint a, bool b) {
        // 命名返回值后，可以隐式返回，不需要return关键字
        a = 1;
        b = true;
    }

    function returnAssignment() external pure returns (uint, bool, bool) {
        (uint a, bool b) = returnMulti();
        // 不需要第一个返回值
        (, bool _b) = returnMulti();
        return (a, b, _b);
    }
}
