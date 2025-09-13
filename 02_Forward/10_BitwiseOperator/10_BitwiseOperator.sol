// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容：位运算
contract BitwiseOpt {
    // 与
    // x 14 -> 1110
    // y 11 -> 1011
    // x&y  -> 1010
    function and(uint x, uint y) external pure returns (uint) {
        return x & y;
    }

    // 或
    // x 12 -> 1100
    // y  9 -> 1001
    // x|y  -> 1101
    function or(uint x, uint y) external pure returns (uint) {
        return x | y;
    }

    // 异或
    // x 12 -> 1100
    // y  9 -> 0101
    // x^y  -> 1001
    function xor(uint x, uint y) external pure returns (uint) {
        return x ^ y;
    }

    // 非（取反）
    // x 12 -> 00001100
    // ~x   -> 11110011 -> 128 + 64 + 32 + 16 + 2 + 1  = 243
    function not(uint8 x) external pure returns (uint8) {
        return ~x;
    }

    // 1 << 1 -> 0001 -> 0010
    // 1 << 2 -> 0001 -> 0100
    // 1 << 3 -> 0001 -> 1000
    // 3 << 2 -> 0011 -> 1100
    function shiftLeft(uint x, uint moveBit) external pure returns (uint) {
        return x << moveBit;
    }

    // 8 >> 4 -> 1000 -> 0000 无符号高位补0
    function shiftRight(uint x, uint moveBit) external pure returns (uint) {
        return x >> moveBit;
    }

    // 应用
    // 将x返回最后n位的值的两种写法：
    // 方式一：掩码
    function getLastNBits(uint x, uint n) external pure returns (uint) {
        // 比如x为1101，n为3，返回x的后3位结果为0101
        // 使用掩码进行与运算，掩码mask为0111
        // 0111 & 1101 -> 0101

        // mask的两种方式
        // 两种方式的原理是相同的，比如mask为0111，先得到二进制1000后减1，得到0111
        // uint mask = (1 << n) - 1;
        uint mask = 2 ** n - 1;

        return x & mask;
    }

    // 方式二：取模
    function getLastNBitsByMod(uint x, uint n) external pure returns (uint) {
        return x % (1 << n);
    }
}

// 使用位运算计算一个数字的最高有效位
contract MostSignficantBit {
    // 返回值为什么用uint8？ - 因为uint256共256位，需求要求返回最高位的位数，因此最大为256，uint8可表示的最大值为2**8=256
    // 使用二分查找
    function findMostSignficantBit(uint256 x) external pure returns (uint8 r) {
        if (x >= 2 ** 128) {
            x >>= 128;
            r += 128;
        }
        if (x >= 2 ** 64) {
            x >>= 64;
            r += 64;
        }
        if (x >= 2 ** 32) {
            x >>= 32;
            r += 32;
        }
        if (x >= 2 ** 16) {
            x >>= 16;
            r += 16;
        }
        if (x >= 2 ** 8) {
            x >>= 8;
            r += 8;
        }
        if (x >= 2 ** 4) {
            x >>= 4;
            r += 4;
        }
        if (x >= 2 ** 2) {
            x >>= 2;
            r += 2;
        }
        if (x >= 2) {
            r += 1;
        }
    }
}
