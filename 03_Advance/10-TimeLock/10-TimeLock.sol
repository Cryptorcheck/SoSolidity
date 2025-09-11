// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容：时间锁 - defi和dao中经常使用的合约，可以延迟交易的执行
// 当执行一笔交易时，将交易入队，存储在time lock时间锁的queue队列中，到一定时间后去执行交易。在等待过程中，可以去检查交易有没有风险
// 场景：升级合约、转移资产、修改预言机

contract TimeLock {
    address public owner;
    mapping(bytes32 txId => bool isExistInQueue) public txIdToIsExistInQueueMap;

    uint public constant MIN_DELAY = 10; // 生产环境通常是几天或几周
    uint public constant MAX_DELAY = 1000; // 生产环境可能到30天
    uint public constant GRACE_PERIOD = 1000; // 宽限时间，执行时间超过宽限周期后将不能执行

    error NoAuthError();
    error AlreadyExist(bytes32 txId);
    error TxNotExistInQueue(bytes32 txId);
    error TimestampNotInRange(uint bt, uint t);
    error TimestampNotYet(uint bt, uint t);
    error TimestampExpired(uint bt, uint expiredAt);
    error TxError();

    event TxPushInQueue(
        bytes32 indexed txId,
        address target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Cancel(bytes32 indexed txId);

    constructor() {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        if (msg.sender != owner) {
            revert NoAuthError();
        }
        _;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns (bytes32 txId) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    // 入队
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external {
        // 创建交易id
        bytes32 _txId = getTxId(_target, _value, _func, _data, _timestamp);

        // 检查交易id唯一性
        if (txIdToIsExistInQueueMap[_txId]) {
            revert AlreadyExist(_txId);
        }

        // 检查执行时间戳是否在当前在当前区块时间戳之后
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRange(block.timestamp, _timestamp);
        }

        // 交易入队
        txIdToIsExistInQueueMap[_txId] = true;
        emit TxPushInQueue(_txId, _target, _value, _func, _data, _timestamp);
    }

    receive() external payable {}

    // 执行
    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable OnlyOwner returns (bytes memory) {
        bytes32 _txId = getTxId(_target, _value, _func, _data, _timestamp);
        // 检查交易是否入队
        if (!txIdToIsExistInQueueMap[_txId]) {
            revert TxNotExistInQueue(_txId);
        }
        // 检查执行时间戳
        if (_timestamp > block.timestamp) {
            revert TimestampNotYet(block.timestamp, _timestamp);
        }
        // 判断交易是否超过宽限周期
        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimestampExpired(block.timestamp, _timestamp + GRACE_PERIOD);
        }

        // 从队列中删除交易
        txIdToIsExistInQueueMap[_txId] = false;

        bytes memory data;

        if (bytes(_func).length > 0) {
            data = abi.encodePacked(
                bytes4(keccak256(bytes(_func))), // 函数选择器
                _data
            );
        } else {
            data = _data;
        }

        // 执行交易
        (bool ok, bytes memory res) = _target.call{value: _value}(data);

        if (!ok) {
            revert TxError();
        }

        emit Execute(_txId, _target, _value, _func, _data, _timestamp);

        return res;
    }

    // 取消入队
    function cancel(bytes32 txId) external {
        require(txIdToIsExistInQueueMap[txId], "not in queue");
        txIdToIsExistInQueueMap[txId] = false;
        emit Cancel(txId);
    }
}

contract Test {
    address public timelock;

    constructor(address _lock) {
        timelock = _lock;
    }

    function exec() external view {
        require(msg.sender == timelock, "");
    }

    // 辅助函数，用于测试时获取当前时间戳 + 100s，表示100s后可以调用exec函数
    function getTimestamp() external view returns (uint) {
        return block.timestamp + 100;
    }
}
