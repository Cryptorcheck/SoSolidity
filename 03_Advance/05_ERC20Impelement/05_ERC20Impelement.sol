// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

// 币安智能链标准
// interface IBEP20 {
//   function totalSupply() external view returns (uint256);
//   function decimals() external view returns (uint8);
//   function symbol() external view returns (string memory);
//   function name() external view returns (string memory);
//   function balanceOf(address account) external view returns (uint256);
//   function transfer(address recipient, uint256 amount) external returns (bool);
//   function allowance(address _owner, address spender) external view returns (uint256);
//   function approve(address spender, uint256 amount) external returns (bool);
//   function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
//   event Transfer(address indexed from, address indexed to, uint256 value);
//   event Approval(address indexed owner, address indexed spender, uint256 value);
// }

// 以下是非标准erc20
// contract IERC20 {
//     uint public _totalSupply;
//     function totalSupply() public constant returns (uint);
//     function balanceOf(address who) public constant returns (uint);
//     function transfer(address to, uint value) public;
// 	   function allowance(address owner, address spender) public constant returns (uint);
//     function transferFrom(address from, address to, uint value) public;
//     function approve(address spender, uint value) public;
//     event Approval(address indexed owner, address indexed spender, uint value);
//     event Transfer(address indexed from, address indexed to, uint value);
// }

// 本节内容：实现一个ERC20的合约

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);
}

contract ERC20Impl is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] = amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
