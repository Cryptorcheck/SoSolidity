// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容-gas优化的一些方法

/**
1、使用calldata
2、加载状态变量到内存中 - load state variables to memory
3、短路 - short circuit
4、循环增量 - loop increments
5、缓存数组长度 - cache array length
6、加载数组元素到内存中 - load array elements to memory
*/

contract GasGolf {
    uint public total;

    // 未优化前的函数，查看消耗的gas - 57199gas
    // nums: [1,2,3,4,5,100]
    function sumIfEvenAndLessThan99_1(uint[] memory nums) external {
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    // 优化calldata后 - 55212
    function sumIfEvenAndLessThan99_2(uint[] calldata nums) external {
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    // 加载状态变量到内存中后 - 55020
    function sumIfEvenAndLessThan99_3(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                _total += nums[i];
            }
        }

        total = _total;
    }

    // 短路优化后 - 54636
    function sumIfEvenAndLessThan99_4(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; i++) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }

        total = _total;
    }

    // 加载数组元素到内存中 - 54484
    function sumIfEvenAndLessThan99_5(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; ++i) {
            uint e = nums[i];
            if (e % 2 == 0 && e < 99) {
                _total += e;
            }
        }

        total = _total;
    }
}
