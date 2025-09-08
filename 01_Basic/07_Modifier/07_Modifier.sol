// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 函数装饰器
// Basic基础装饰器  inputs装饰器入参  sandwich三明治装饰器
contract FunctionModitier {
    bool public paused;
    uint public count;

    function setPasused(bool _paused) external {
        paused = _paused;
    }

    // 不使用装饰器的函数
    function inc() external {
        require(!paused, "paused");
        count += 1;
    }

    // 不使用装饰器的函数
    function dec() external {
        require(!paused, "paused");
        count -= 1;
    }

    /**
     Basic基础装饰器
     */
    //装饰器函数
    modifier Decorator() {
        require(!paused, "paused");
        // 下划线表示执行被装饰的函数
        _;
    }

    // 使用装饰器
    function inc1() external Decorator {
        require(!paused, "paused");
        count += 1;
    }

    // 使用装饰器
    function dec1() external Decorator {
        require(!paused, "paused");
        count -= 1;
    }

    /**
     inputs装饰器入参
     */
    // 接收参数的装饰器
    modifier DecoratorByArgs(uint _a) {
        require(_a < 100, "_x > 100");
        _;
    }

    // 多装饰器，接收参数的装饰器的使用
    function inc2(uint _x) external Decorator DecoratorByArgs(_x) {
        require(_x < 100, "_x > 100");
        count += _x;
    }

    /**
     sandwich三明治装饰器，装饰器代码在被装饰函数代码执行的前后分别执行
     */
    modifier sandwich() {
        count += 1;
        _;
        count *= 2;
    }

    function incBySandwich() external sandwich {
        count += 1;
    }
}
