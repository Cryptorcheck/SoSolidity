// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

///
/// call
contract TestCall {
    string public message;
    uint public x;

    event Log(address sender, uint256 val, string message);

    receive() external payable {}

    fallback() external payable {
        emit Log(msg.sender, msg.value, "call fullback");
    }

    function foo(
        string memory _msg,
        uint256 _x
    ) public payable returns (bool, uint) {
        message = _msg;
        x = _x;
        return (true, 999);
    }
}

contract Call {
    bytes public data;

    function call(address _testCall) external payable {
        // call{value: 111, gas: 5000} - gas限制为5000，如果修改状态变量，5000gas的限制可能不够
        (bool ok, bytes memory _data) = _testCall.call{value: 111}(
            abi.encodeWithSignature("foo(string,uint256)", "test msg", 123)
        );
        require(ok, "not ok");
        data = _data;
    }

    function callNotExist(address _testCall) external {
        (bool ok, ) = _testCall.call(abi.encodeWithSignature("notExistFunc()"));
        require(ok, "not ok");
    }
}
