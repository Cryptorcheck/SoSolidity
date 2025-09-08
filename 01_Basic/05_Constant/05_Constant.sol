// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 常量 - 合约编译时确定，存储在合约字节码中
contract Constants {
    // 常量可以节约gas，从而降低手续费
    // 常量调用消耗356gas
    address public constant MY_ADDR =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    // 变量调用消耗2511gas
    address public myAddr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
}

// 不可变性 变量（节省gas）
// immutable变量 - 在合约部署时确定，存储在合约字节码中
contract Immutable {
    // immutable修饰的变量只能在部署时初始化，部署后不可修改。一般在constructor初始化
    address public immutable owner = msg.sender;
    address public immutable owner1;
    uint public x;

    constructor(address _ad) {
        owner1 = _ad;
    }

    function foo() external {
        require(owner == msg.sender);
        x++;
    }
}
