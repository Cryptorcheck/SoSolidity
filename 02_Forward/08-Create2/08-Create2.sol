// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容：使用Create2提前计算合约部署地址

contract DeployWithCreate2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

contract Create2Factory {
    event Deploy(address addr);

    // 部署合约
    function deploy(uint _salt) external {
        // 这是传统的new关键字部署合约
        // DeployWithCreate2 _contract = new DeployWithCreate2(msg.sender);
        // emit Deploy(address(_contract));

        // 使用create2方式部署合约
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: bytes32(_salt)
        }(msg.sender);
        emit Deploy(address(_contract));
    }

    // 计算合约部署地址
    function getContractDeployAddress(
        bytes memory bytecode,
        uint _salt
    ) external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        // hash是32字节，我们需要得到的是一个20字节的地址，20 / 32 = 0.625
        // 转换成uint256后，就需要取前160位，160 / 256 = 0.625
        return address(uint160(uint256(hash))); // 固定写法
    }

    // 计算要部署的合约的bytecode，同时要将DeployWithCreate2合约初始化的入参owner带入bytecode
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        // 将入参onwer编码到bytecode，返回一个携带了构造函数参数的bytecode
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}
