// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 本节内容：异常处理

contract ErrorHandler {
    // require
    function testRequire(uint i) external pure returns (uint8) {
        require(i <= 10, "Err: i > 10");
        return 10;
    }

    // revert
    function testRevert(uint i) external pure {
        if (i > 10) {
            revert("i > 10");
        }
    }

    // assert断言
    uint8 public num = 123;

    function testAssert() public view {
        assert(num == 123);
    }

    // 自定义错误：如果报错的字符串信息非常长，可以使用自定义错误，节省gas
    error MyError(address caller, uint8 i);

    function testCustomError(uint8 i) public view {
        if (i > 10) {
            revert MyError(msg.sender, i);
        }
    }

    // 抛出异常后，gas费退还以及状态回滚
    function foo() public {
        num++;
        // 抛出异常后数据回滚，num的状态不会被修改，gas费也会被退还
        require(num <= 10, "num > 10");
    }
}
