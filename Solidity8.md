# Solidity 8 新特性

## safe math 
- 安全数学，Solidity 8 以前，uint有溢出
```sol
contract SafeMath {
  function testUnderFlow() public pure returns(uint) {
    uint x = 0;
    // x-- 后溢出，因为有安全数学校验导致报错
    x--;
    return x;
  }

  function testUncheckUnderFlow() public pure returns(uint) {
    uint x = 0;
    // unchecked可以得到无安全数学的结果，得到uint256的最大值 
    unchecked{ x--; } 
    return x;
  }
}
```

## 自定义错误
```sol
contract CustomError {
  address public owner;
  constructor () {
    owner = msg.sender;
  }

  function testRevert() public {
    if (msg.sender != owner) {
      revert("error"); // 消耗gas与字符串长度有关
    }
  }

  // 自定义错误
  error Unauthorized(address caller);

  function testCustomRevert() public {
    if (msg.sender != owner) {
      // revert自定义错误
      revert Unauthorized(msg.sender);
    }
  }
}
```

## 合约外函数
- 合约外函数类似library中的工具函数，无法访问状态变量
```sol
function helper (uint x) pure returns(uint) {
  return x * 2;
}

contract TestHelper {
  function test () public {
    return helper(123);
  }
}
```

## import别名
```sol
import { Unauthorized, helper as helper1  } from "./Sol.sol"

function helper () pure returns(uint) {
  return x * 2;
}
```

## Create2使用
