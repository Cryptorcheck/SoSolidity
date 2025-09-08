// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 异常处理
contract ErrorHandler {
    // 抛出错误，会调用revert，返回给调用者。不会影响后续的执行
    function testRequire(uint i) external pure returns (uint8) {
        // revert "error msg"；msg可以省略
        require(i <= 10, "Err: i > 10");
        return 10;
    }

    function testRevert(uint i) external pure {
        if (i > 10) {
            revert("i>10");
        }
    }

    uint8 public num = 123;

    function testAssert() public view {
        assert(num == 123);
    }

    function foo() public {
        num++;
    }

    // 自定义错误，节省gas
    error MyError(address caller, uint8 i);

    function testCustomError(uint8 i) public view {
        if (i > 10) {
            revert MyError(msg.sender, i);
        }
    }
}
