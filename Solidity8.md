# Solidity 8 新特性

## safe math 
- 安全数学，Solidity 8 以前，uint有溢出
```sol
contract SafeMath {
  function testUnderFlow() public pure returns(uint) {
    uint x = 0;
    x--;
    return x;
  }

  function testUncheckUnderFlow() public pure returns(uint) {
    uint x = 0;
    unchecked{ x--; } // unchecked可以得到无安全数学的结果
    return x;
  }
}
```

## 自定义错误
- 

## 合约外函数
- 

## import别名

## Create2
