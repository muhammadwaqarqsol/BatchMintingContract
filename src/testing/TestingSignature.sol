//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {orderTypes} from "../libraries/orderTypes.sol";

error ZeroAddress();
error InvalidSignature();
error AlreadyExecuted();

contract MyToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable, EIP712Upgradeable {
    
    using orderTypes for orderTypes.OrderItem;

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => mapping(uint256 => bool)) private _isUserClaimNonceExecuted;

    function initialize(address initialOwner) public initializer {
        __ERC1155_init("");
        __Ownable_init(initialOwner);
        transferOwnership(initialOwner);
    }

    function setURI(uint256 tokenId, string memory newuri) public onlyOwner {
        _tokenURIs[tokenId] = newuri;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function executeIfSignatureMatch(orderTypes.OrderItem calldata orderItem)
        internal
        view
        returns (bool)
    {
        if (_isUserClaimNonceExecuted[orderItem.nft_Owner][orderItem.nonce]) {
            revert AlreadyExecuted();
        }

        bytes32 eip712DomainHash = domainHash();
        bytes32 hashStruct = generateHashForOrder(
            orderItem.nft_Owner,
            orderItem.nft_Buyer,
            orderItem.tokenId,
            orderItem.quantity,
            orderItem.data,
            orderItem.nonce
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );
        address signer = ecrecover(hash, orderItem.v, orderItem.r, orderItem.s);
        return signer == orderItem.nft_Owner;
    }

    function domainHash() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,address verifyingContract)"),
                keccak256(bytes("Marketplace")),
                keccak256(bytes("1")),
                address(this)
            )
        );
    }

    function generateHashForOrder(
        address _owner,
        address _buyer,
        uint256 _tokenId,
        uint256 _quantity,
        bytes memory _data,
        uint256 _nonce
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                keccak256("OrderItem(address nft_Owner,address nft_Buyer,uint256 tokenId,uint256 quantity,bytes data,uint256 nonce)"),
                _owner,
                _buyer,
                _tokenId,
                _quantity,
                _data,
                _nonce
            )
        );
    }

    function mintWithSignature(orderTypes.OrderItem calldata orderItem) external {
        require(executeIfSignatureMatch(orderItem), "Invalid signature");
        _isUserClaimNonceExecuted[orderItem.nft_Owner][orderItem.nonce] = true;
        _mint(orderItem.nft_Buyer, orderItem.tokenId, orderItem.quantity, orderItem.data);
    }
}
