// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容：众筹（资金募集，发起者通过某个公开平台向大众募集资金）

/**
单次众筹合约架构：
角色：
    发起者
    支持者
功能：
    发起/取消众筹（发起者）
    认捐资金（支持者）
    撤回认捐（支持者）
    提取资金（发起者）
    失败退款（支持者）
部署测试：
    帐户准备：
        账户1 发起众筹 launch
        帐户2 认捐资金 pledge
        帐户3 认捐资金 pledge
    合约部署：
        MyToken合约
        CrowdFund合约
    测试：
        首先需要保证帐户2和帐户3中又充足的token，（MyToken合约owner）需要先调用MyToken合约中的transfer为两个帐户充值余额
        帐户2和帐户3通过MyToken合约approve授权给CrowdFund合约
        帐户1调用CrowdFund合约launch开启众筹
        帐户2和帐户3通过CrowdFund合约pledge认捐
        帐户1调用CrowdFund合约claim提取资金
*/

// 多轮众筹合约实现
contract CrowdFund {
    struct FundCampaign {
        // 发起人
        address creator;
        // 资金目标
        uint goal;
        // 已募资
        uint pledged;
        uint startAt;
        uint expiredAt;
        // 发起人是否已提取
        bool isClaimed;
    }
    // 募集代币类型
    IERC20 public immutable token;
    // 轮次
    uint public round;
    // 多轮募资信息
    mapping(uint round => FundCampaign) fundCampaigns;
    // 多轮筹集到资金
    mapping(uint round => mapping(address => uint)) public pledgedAmount;

    event Launch(
        uint round,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 expiredAt
    );
    event Cancel(uint round);
    event Pledge(uint round, address indexed pledger, uint amount);
    event Unpledge(uint round, address indexed pledger, uint amount);
    event Claim(uint round);
    event Refund(uint round, address indexed pledger, uint amount);

    constructor(address _tokenContractAddr) {
        token = IERC20(_tokenContractAddr);
    }

    // 发起众筹（发起者）
    function launch(
        uint _goal,
        uint32 _startAtOffset,
        uint32 _expiredAtOffset
    ) external {
        require(_expiredAtOffset > _startAtOffset, "end time < start time");
        require(_expiredAtOffset <= 30 days, "_expiredAtOffset too large");

        uint32 _startAt = uint32(block.timestamp) + _startAtOffset;
        uint32 _expiredAt = uint32(block.timestamp) + _expiredAtOffset;

        round += 1;

        fundCampaigns[round] = FundCampaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            expiredAt: _expiredAt,
            isClaimed: false
        });

        emit Launch(round, msg.sender, _goal, _startAt, _expiredAt);
    }

    // 取消众筹（发起者）
    function cancel(uint _round) external {
        FundCampaign memory campaign = fundCampaigns[_round];
        require(msg.sender == campaign.creator, "no auth");

        // 众筹活动尚未开始才可取消
        require(campaign.startAt > block.timestamp, "campaign has started");
        delete fundCampaigns[_round];
        emit Cancel(_round);
    }

    // 认捐资金（支持者）
    function pledge(uint _round, uint _amount) external payable {
        // 此处需要修改fundCampaigns中的数据，因此需要拿storage指针
        FundCampaign storage campaign = fundCampaigns[_round];
        require(campaign.startAt <= block.timestamp, "campaign don't start");
        require(campaign.expiredAt >= block.timestamp, "campaign has expired");
        campaign.pledged += _amount;
        pledgedAmount[_round][msg.sender] += _amount;

        // 转账
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_round, msg.sender, _amount);
    }

    // 撤回认捐（支持者）
    function unpledge(uint _round, uint _amount) external {
        FundCampaign storage campaign = fundCampaigns[_round];

        require(block.timestamp <= campaign.expiredAt, "ended");
        campaign.pledged -= _amount;
        pledgedAmount[_round][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Unpledge(_round, msg.sender, _amount);
    }

    // 提取资金（发起者）
    function claim(uint _round) external {
        FundCampaign storage campaign = fundCampaigns[_round];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.expiredAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.isClaimed, "claimed");
        campaign.isClaimed = true;

        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_round);
    }

    // 失败退款（支持者）
    function refund(uint _round) external {
        FundCampaign storage campaign = fundCampaigns[_round];
        require(block.timestamp > campaign.expiredAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        uint balance = pledgedAmount[_round][msg.sender];
        pledgedAmount[_round][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit Refund(_round, msg.sender, balance);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract MyToken is ERC20 {
    constructor() ERC20("CrowdFundToken", "CFT", 18) {
        _mint(msg.sender, 10000000 * 10 ** uint256(decimals));
    }
}
