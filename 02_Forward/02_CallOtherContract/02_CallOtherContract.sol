// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Caller {
    // 调用其他合约方式一：传入地址，直接指明合约类型直接访问
    function setX(Controller _con, uint _x) external {
        _con.setX(_x);
    }

    // 调用其他合约方式二：传入地址，使用地址 + 合约实例化访问
    function getX(
        address _controllerContractAddress
    ) external view returns (uint) {
        return Controller(_controllerContractAddress).getX();
    }

    function setXAndSenderEth(address _con, uint _x) external payable {
        Controller(_con).setAndSendEth{value: msg.value}(_x);
    }

    function getXAndVal(
        Controller _con
    ) external view returns (uint x, uint val) {
        (x, val) = _con.getXAndVal();
    }
}

contract Controller {
    uint256 public x;
    uint256 public val = 123;

    function setX(uint256 _x) public returns (uint) {
        x = _x;
        return x;
    }

    function getX() external view returns (uint) {
        return x;
    }

    function setAndSendEth(uint256 _x) public payable {
        x = _x;
        val = msg.value;
    }

    function getXAndVal() external view returns (uint, uint) {
        return (x, val);
    }
}
