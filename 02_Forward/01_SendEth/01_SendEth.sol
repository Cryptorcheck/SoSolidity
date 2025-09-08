// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract SendEther {
    constructor() payable {}

    receive() external payable {}

    // 简单场景
    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(12);
    }

    function sendViaSend(address payable _to) external payable {
        bool ok = _to.send(12);

        require(ok, "send fail");
    }

    // 常用call
    function sendViaCall(address payable _to) external payable {
        (bool ok, ) = _to.call{value: 123}("");

        require(ok, "send fail");
    }
}

contract EthReceiver {
    event Log(uint amount, uint gas);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}
