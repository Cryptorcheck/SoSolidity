// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 本节内容：WETH合约（通常在一些Defi项目使用）
// 该合约会把以太转成标准的ERC20 token。当提取的时候，合约会把ERC20 token销毁（burn），将以太返还用户。
// 当一个项目合约需要和以太和ERC20同时交互时，不需要编写两套合约同时支持以太和ERC20。只需要编写一套针对ERC20的合约即可，当项目需要用到以太时，调用WETH（Wrapped ETH）即可

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    // 对父类构造函数初始化 ERC20(name,symbol)
    constructor() ERC20("Wrapper Eth", "WETH") {}

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    // 如果用户不小心将以太直接转给合约而没有调用deposit，需要一个fallback方法
    fallback() external payable {
        deposit();
    }

    // 存款
    // 用户将以太发送给合约，合约会mint一个ERC20 token给用户
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // 提款
    function withdraw(uint _amount) external {
        // 先burn再发送以太，防止重入
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}
