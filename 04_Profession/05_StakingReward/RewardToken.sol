// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    constructor(uint initialSupply) ERC20("RewardToken", "RTK") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint val) public {
        _mint(to, val);
    }
}
