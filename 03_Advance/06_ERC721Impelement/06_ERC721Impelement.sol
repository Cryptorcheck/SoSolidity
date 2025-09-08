// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    /// @notice 查询owner地址持有的NFT数量
    function balanceOf(address owner) external view returns (uint256 balance);

    /// @notice 查询tokenId的所有者地址
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /// @notice 安全转移NFT（无data参数）
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice 安全转移NFT（自动检查接收合约是否支持ERC721）
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /// @notice 普通转移NFT（不检查接收方兼容性，慎用）
    function transferFrom(address from, address to, uint256 tokenId) external;

    /// @notice 授权另一地址管理指定的tokenId
    function approve(address to, uint256 tokenId) external;

    /// @notice 查询被授权管理特定tokenId的地址
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /// @notice 授权或取消授权operator管理调用者所有NFT
    function setApprovalForAll(address operator, bool approved) external;

    /// @notice 检查operator是否被授权管理owner的所有NFT
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Recevied(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    mapping(uint => address) internal _ownerOf; // 代表nftId属于谁，一个tokenId对应一个地址
    mapping(address => uint) internal _balanceOf; // 代表某个地址拥有多少个NFT
    mapping(uint => address) internal _tokenApprovals; // 代表某个NFT tokenId的授权使用地址，某个用户调用approve后存储到此
    mapping(address => mapping(address => bool)) public isApprovedForAll; // 代表某用户授权另一个用户管理所有NFT

    // 如果interfaceID符合IERC721或者IERC165的interfaceId，表示支持这些接口，返回true
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId;
    }

    /// @notice 查询owner地址持有的NFT数量
    function balanceOf(address _owner) external view returns (uint256 balance) {
        require(_owner != address(0), "cannot be 0");
        balance = _balanceOf[_owner];
    }

    /// @notice 查询tokenId的所有者地址
    function ownerOf(uint256 tokenId) external view returns (address owner) {
        owner = _ownerOf[tokenId];
        require(owner != address(0), "address = 0");
    }

    /// @notice 授权或取消授权operator管理调用者所有NFT
    function setApprovalForAll(address operator, bool _approved) external {
        // msg.sender 授权给 operator
        isApprovedForAll[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    /// @notice 授权另一地址管理指定的tokenId
    function approve(address to, uint256 tokenId) external {
        address owner = _ownerOf[tokenId];
        require(
            owner == msg.sender || isApprovedForAll[owner][msg.sender],
            "no authorized"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// @notice 查询被授权管理特定tokenId的地址
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator) {
        require(_ownerOf[tokenId] != address(0), "cannot be address 0");
        operator = _tokenApprovals[tokenId];
    }

    // 检查tokenId是否有权限被使用者消费，返回是否有权限的bool
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        return
            owner == spender ||
            isApprovedForAll[owner][spender] ||
            spender == _tokenApprovals[tokenId];
    }

    /// @notice 普通转移NFT（不检查接收方兼容性，慎用）
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(from == _ownerOf[tokenId], "from != owner");
        require(to != address(0), "to cannot be address 0");
        require(_isApprovedOrOwner(from, msg.sender, tokenId), "not authorize");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId] = to;

        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    /// @notice 安全转移NFT（无data参数）
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {
        transferFrom(from, to, tokenId);
        // 需要判断接收地址是不是合约，如果不是合约可以直接进行调用，如果是合约，就需要通过onERC721Recevier检查合约是否支持ERC721
        // to.code.length = 0 说明to是正常EOA账户地址
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Recevied(
                    msg.sender,
                    from,
                    tokenId,
                    ""
                ) ==
                IERC721Receiver.onERC721Recevied.selector,
            "unsafe recipient"
        );
    }

    /// @notice 安全转移NFT（自动检查接收合约是否支持ERC721）
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external {
        transferFrom(from, to, tokenId);
        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Recevied(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) ==
                IERC721Receiver.onERC721Recevied.selector,
            "unsafe recipient"
        );
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "addr cannot 0");
        require(_ownerOf[tokenId] != address(0), "token not exists");

        _balanceOf[to]++;
        _ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "owner cannot address 0");

        _balanceOf[owner]--;
        delete _ownerOf[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }
}

// 实现简单NFT
contract MyNFT is ERC721 {
    function mint(address to, uint tokenId) external {
        _mint(to, tokenId);
    }

    function burn(uint tokenId) external {
        require(msg.sender == _ownerOf[tokenId], "no authorized");
        _burn(tokenId);
    }
}
