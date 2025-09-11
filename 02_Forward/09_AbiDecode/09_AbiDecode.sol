// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// abi解码

contract AbiDecode {
    struct TestStruct {
        string name;
        uint[2] nums;
    }

    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        TestStruct calldata testStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, testStruct);
    }

    function decode(
        bytes calldata data
    )
        external
        pure
        returns (
            uint x,
            address addr,
            uint[] memory arr,
            TestStruct memory testStruct
        )
    {
        (x, addr, arr, testStruct) = abi.decode(
            data,
            (uint, address, uint[], TestStruct)
        );
    }
}
