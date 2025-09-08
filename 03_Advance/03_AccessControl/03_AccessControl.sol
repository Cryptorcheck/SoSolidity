// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 本节内容：
// 访问控制，通过角色判断是否有调用某个函数的权限

contract AccessControl {
    // 使用嵌套mapping，role => ( account address => bool )
    // 为什么role是bytes32类型而不是string？因为角色名过长就需要对其进行hash，可以节省gas
    mapping(bytes32 => mapping(address => bool)) public roles;

    bytes32 private constant ADMIN_ROLE =
        keccak256(abi.encodePacked("ADMIN_ROLE"));
    bytes32 private constant USER_ROLE =
        keccak256(abi.encodePacked("USER_ROLE"));

    // 使用indexed修饰，可以方便查找
    event GrantRole(bytes32 indexed _role, address indexed _addr);
    event RevokeRole(bytes32 indexed _role, address indexed _addr);

    constructor() {
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // 角色鉴权，调用者是否符合权限，因此检查的是msg.sender的权限
    modifier OnlyRole(bytes32 _role) {
        require(roles[_role][msg.sender], "Access Forbidden");
        _;
    }

    // 授予账号某角色
    function _grantRole(bytes32 _role, address _acc) internal {
        roles[_role][_acc] = true;
        emit GrantRole(_role, _acc);
    }

    function grantRole(
        bytes32 _role,
        address _acc
    ) external OnlyRole(ADMIN_ROLE) {
        _grantRole(_role, _acc);
    }

    // 撤销某账号的某权限
    function _revokeRole(bytes32 _role, address _acc) internal {
        roles[_role][_acc] = false;
        emit RevokeRole(_role, _acc);
    }

    function revokeRole(
        bytes32 _role,
        address _acc
    ) external OnlyRole(ADMIN_ROLE) {
        _revokeRole(_role, _acc);
    }
}
