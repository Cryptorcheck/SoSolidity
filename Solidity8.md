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

  // 自定义错误，可以节约gas
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
- 使用Create2部署合约可以提前计算部署地址
  - 一般合约部署方法，合约地址使用nonce值进行计算
  - Create2部署方法使用salt盐进行计算合约地址，因此，可以得到一个确定的地址
    - 这种方式在uniswap的配对合约中经常使用
- solidity 8 以前使用 Create2，必须在内联汇编中加盐使用
```sol
contract Create2Factory {
  function test () public {
    assembly {
      addr := create2(
        callvalue(),
        add(bytecode, 0x20),
        mload(bytecode),
        _salt
      )
      if iszero(extcodesize(addr)) {
        revert(0,0)
      }
    }
  }
}
```

```sol
contract Create2Factory {
    event Deploy(address addr);

    // 部署合约
    function deploy (uint _salt) external {
        // 这是传统的new关键字部署合约
        // DeployWithCreate2 _contract = new DeployWithCreate2(msg.sender);
        // emit Deploy(address(_contract));

        // 使用create2方式部署合约
        DeployWithCreate2 _contract = new DeployWithCreate2{salt: bytes32(_salt)}(msg.sender);
        emit Deploy(address(_contract));
    }

    // 计算合约部署地址
    // @param bytecode来自getBytecode
    function getContractDeployAddress (bytes memory bytecode, uint _salt) external view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this), 
            _salt,
            keccak256(bytecode)
        ));

        // hash是32字节，我们需要得到的是一个20字节的地址，20 / 32 = 0.625
        // 转换成uint256后，就需要取前160位，160 / 256 = 0.625
        return address(uint160(uint256(hash))); // 固定写法
    }

    // 计算要部署的合约的bytecode，同时要将DeployWithCreate2合约初始化的入参owner带入bytecode
    function getBytecode (address _owner) public pure returns (bytes memory ){
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        // 将入参onwer编码到bytecode，返回一个携带了构造函数参数的bytecode
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}
```