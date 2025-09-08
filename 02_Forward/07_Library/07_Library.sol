// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 本节内容：使用library关键字，复用代码
//library关键字不能拥有状态变量
library Math {
    function max(uint a, uint b) internal pure returns (uint) {
        return a > b ? a : b;
    }
}

contract Test {
    function compare(uint a, uint b) external pure returns (uint) {
        return Math.max(a, b);
    }
}

library Array {
    function findIndex(
        uint[] storage arr,
        uint _num
    ) internal view returns (uint i) {
        for (i = 0; i < arr.length; i++) {
            if (arr[i] == _num) {
                return i;
            }
        }
        revert("not found");
    }
}

contract TestArr {
    using Array for uint[]; // 方式二前置条件：使用using for 将Array library的方法赋予uint[]
    uint[] arr = [3, 2, 1];

    // 方式一
    function findIndex(uint _num) external view returns (uint) {
        return Array.findIndex(arr, _num);
    }

    // 方式二
    function findIndex2(uint _num) external view returns (uint) {
        return arr.findIndex(_num);
    }
}
