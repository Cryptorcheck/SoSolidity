// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 本节内容：多签钱包

contract MultiSigWallet {
    // 事件
    event Deposit(address indexed sender, uint amount); // 存款事件，当用户存款时发送
    event Submit(uint indexed transactionId); // 提交事件，用户执行交易首先需要把交易提交到钱包中，transactionId 交易id
    event Approve(address indexed owner, uint indexed transactionId); // owner授权交易
    event Revoke(address indexed owner, uint indexed transactionId); // owner撤销交易
    event Execute(uint indexed transationId); // 执行交易

    // 状态变量
    address[] public owners;
    mapping(address => bool) isOwner; // 使用mapping存储所有owner，用于快速判断是不是owner
    uint public minApproveCountByOwners = 2; // 至少需要多少个owner同意交易后，交易才可以执行

    struct Transaction {
        address to;
        uint value; // 交易金额
        bytes data;
        bool executed; // 是否被执行过
    }

    Transaction[] public transactions;

    // 某一笔交易被多个owner的审批状态
    // 类似如下结构：
    // {
    //     731935718: {
    //         0x123: true,
    //         0x456: false
    //     }
    // }
    mapping(uint => mapping(address => bool)) public approved;

    // 仅owner可操作校验
    modifier OnlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    // 校验是否交易存在
    modifier TransactionExist(uint _transactionId) {
        require(_transactionId < transactions.length, "transaction not exists");
        _;
    }

    // msg.sender进行授权允许交易时，检查交易是否还未被允许过
    modifier TansactionHaveNotApproved(uint _transactionId) {
        require(
            !approved[_transactionId][msg.sender],
            "transaction already approved"
        );
        _;
    }

    // 交易是否还未被执行过
    modifier TransactionHaveNotExecuted(uint _transactionId) {
        require(
            !transactions[_transactionId].executed,
            "transaction already executed"
        );
        _;
    }

    // _minApproveCountByOwners最小数量
    constructor(address[] memory _owners, uint _minApproveCountByOwners) {
        require(_owners.length > 0, "_owners must be > 0");
        require(
            _minApproveCountByOwners > 0 &&
                _minApproveCountByOwners <= _owners.length,
            "invalid _minApproveCountByOwners"
        );
        owners = _owners;
        minApproveCountByOwners = _minApproveCountByOwners;

        for (uint i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(isOwner[owner], "owner is not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        minApproveCountByOwners = _minApproveCountByOwners;
    }

    // 接收以太并发送存款事件deposit
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 提交交易
    function submit(
        address _to,
        uint _value,
        bytes calldata _data
    ) external OnlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, executed: false})
        );
        emit Submit(transactions.length - 1); // transactions中交易的index就是交易id
    }

    // owner通过该方法允许交易执行
    function approve(
        uint _transactionId
    )
        external
        OnlyOwner
        TransactionExist(_transactionId)
        TansactionHaveNotApproved(_transactionId)
        TransactionHaveNotExecuted(_transactionId)
    {
        approved[_transactionId][msg.sender] = true;
        emit Approve(msg.sender, _transactionId);
    }

    // 检查是否符合最少owner同意
    function isConformMinApproveCountByOwner(
        uint _transactionId
    ) private view returns (uint count) {
        for (uint i; i < owners.length; i++) {
            address owner = owners[i];

            if (approved[_transactionId][owner]) {
                count += 1;
            }
        }
    }

    // 执行交易
    function execute(
        uint _transactionId
    )
        external
        TransactionExist(_transactionId)
        TransactionHaveNotExecuted(_transactionId)
    {
        require(
            isConformMinApproveCountByOwner(_transactionId) >=
                minApproveCountByOwners,
            "approves < minApproveCountByOwners"
        );
        Transaction storage transaction = transactions[_transactionId];
        transaction.executed = true;

        (bool ok, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        require(ok, "transaction failure");

        emit Execute(_transactionId);
    }

    // 撤销交易（应该是撤销approve，因为真正交易后是无法撤销的）
    function revoke(
        uint _transactionId
    )
        external
        OnlyOwner
        TransactionExist(_transactionId)
        TransactionHaveNotExecuted(_transactionId)
    {
        require(approved[_transactionId][msg.sender], "you not approved yet");
        approved[_transactionId][msg.sender] = false;
        emit Revoke(msg.sender, _transactionId);
    }
}
