// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// 本节内容：质押收益

/**
业务介绍：
（1）DiFi领域 
    - 单币质押
        - 平台：AAVE、Compound、LaunchPad（Staking）
        - 原理：用户存入一种代币，获取利益或质押收益
        - 举例：相当于去中心化银行存款，在LaunchPad中存入代币，获取代币奖励
    - 流动性质押
        - 平台：Uniswap、PancakeSwap
        - 原理：用户提供两种代币组成的交易对，换取流动性代币（用户提供代币对，为代币交易池提供流动性，相当于充当做市商的角色）
        - 举例：在Uniswap中提供交易币对，获取交易币对的LP Token，通过LP Token获得奖励或参与其他活动
    - 借贷
        - 平台：AAVE、Compound
        - 原理：用户在平台抵押资产、借出另一种资产，同时获取利息或治理代币利息
        - 举例：在AAVE中存入ETH专区利息，同时获取AAVE代币奖励
      
（2）PoS质押（以太坊） - 通过质押ETH来选择验证人，参与新的区块产生的验证
（3）其他 - GameFi、NFT质押
*/

/**
单币质押的机制和流程： 
（1）两种基于IERC20的代币：质押代币、奖励代币（两种代币可以是同一币种）
（2）奖励机制设置
（3）用户质押代币
（4）角色：管理员、用户
（5）管理员通过质押代币、奖励代币两种token创建质押收益合约
（6）管理员设置奖励持续时间（duration）、奖励数量（amount）、奖励速率（rate）
（7）用户approve代币到质押合约，然后调用质押合约的staking方法
（8）质押合约持续计算质押收益
（9）用户提取reward
*/

/**
单币质押合约实现（理解变量含义和安全性）：
（1）合约变量（代币币种）✅
（2）构造函数（质押代币、奖励代币、管理员）✅
（3）管理员modifier✅
（4）更新收益modifier
（5）设置分配速率和奖励金额（notifyRewardAmount）
（6）函数：质押、撤回、获取收益
（7）状态查询函数
*/

/**
 * 质押收益测试流程
 * 1、部署奖励代币合约，mint总的奖励代币数额转账给质押收益合约的账户
 * 2、部署质押代币合约，mint给参与质押的用户一笔质押代币
 * 3、质押收益合约管理员账户传入奖励代币合约以及质押代币合约，部署质押合约，并设置质押奖励参数
 * 4、用户在质押代币合约中将参与到质押的代币数量授权给质押收益合约
 * 5、用户在质押收益合约进行质押
 * 6、用户提取质押收益到奖励代币合约
 */

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingRewards is Ownable {
    // 代币
    IERC20 public immutable stakingToken; // 质押代币
    IERC20 public immutable rewardToken; // 奖励代币

    // 参数
    uint public duration; // 持续时间
    uint public finishAt;
    uint public updateAt;

    // 奖励速率，每秒奖励token量 -> 奖励总量/duration
    uint public rewardRate;
    // 每质押一个代币获得奖励数
    uint public rewardPerTokenPledge;

    // 记录每个用户每质押一个代币获得奖励数
    mapping(address _user => uint _rewardPerTokenPaid)
        public userRewardPerTokenPaid;

    // 记录每个用户奖励数量
    mapping(address _user => uint reward) public userRewards;

    // 记录每个用户质押数量
    mapping(address _user => uint pledgeAmount) public userPledge;

    // 记录总质押数量
    uint public totalPledge;

    constructor(
        address _stakingTokenAddr,
        address _rewardTokenAddr
    ) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingTokenAddr);
        rewardToken = IERC20(_rewardTokenAddr);
    }

    // 更新用户奖励状态
    modifier UpdateReward(address _user) {
        rewardPerTokenPledge = getRewardPerTokenPledge();
        updateAt = lastTimeRewardApplicable();

        if (_user != address(0)) {
            userRewards[_user] = earned(_user);
            userRewardPerTokenPaid[_user] = rewardPerTokenPledge;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(block.timestamp, finishAt);
    }

    function earned(address _user) public view returns (uint) {
        return 1;
    }

    function _min(uint time1, uint time2) public view returns (uint) {
        return 1;
    }

    // 计算每质押一个代币奖励多少代币
    function getRewardPerTokenPledge() public view returns (uint) {
        if (totalPledge == 0) return rewardPerTokenPledge;
        return
            rewardPerTokenPledge +
            (rewardRate * (lastTimeRewardApplicable() - updateAt) * 1e18) /
            totalPledge;
    }

    // 设置分配速率和奖励金额
    function notifyRewardAmount(
        uint _amount
    ) external onlyOwner UpdateReward(address(0)) {
        // 当前时间超过奖励周期结束时间，创建一个新的奖励周期
        // 当前时间还在奖励周期内，将剩余的奖励和新奖励金额累加后计算新的分配速率
        // 更新奖励周期：奖励结束时间变更为当前时间 + 持续时间duration
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingReward = rewardRate * (finishAt - block.timestamp);
            rewardRate = (remainingReward + _amount) / duration;
        }

        require(rewardRate > 0, "rewardRate cannot = 0");
        require(
            rewardRate * duration >= rewardToken.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updateAt = block.timestamp;
    }

    // 用户质押
    function staking() public {}
}
