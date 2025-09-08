// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 调用未知源码的合约可以通过Interface
// 这个Counter合约被定义在CounterInterface.sol文件
// contract Counter {
//     uint256 public count;
//     function increment() external {
//         count++;
//     }
// }

interface ICounter {
    function count() external view returns (uint);

    function str() external view returns (string memory);

    function increment() external;
}

contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    function getCount(address _counter) external view returns (uint) {
        return ICounter(_counter).count();
    }

    function getStr(address _counter) external view returns (string memory) {
        return ICounter(_counter).str();
    }
}
