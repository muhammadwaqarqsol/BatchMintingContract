// SPDX-License-Identifier: MIT
// pragma solidity 0.8.20;
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
// contract MyToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable {
//     // Mapping from token ID to its custom URI
//     mapping(uint256 => string) private _tokenURIs;

//     // Initialize function instead of constructor
//     function initialize(address creator) public initializer {
//         __ERC1155_init("");
//         __Ownable_init(creator);
//         transferOwnership(creator);
//     }

//     // Function to set the URI for a specific token ID
//     function setURI(uint256 tokenId, string memory newuri) public onlyOwner {
//         _tokenURIs[tokenId] = newuri;
//     }

//     // Override the uri function to return the custom URI for each token ID
//     function uri(uint256 tokenId) public view override returns (string memory) {
//         return _tokenURIs[tokenId];
//     }

//     // Function to mint a new token
//     function mint(address account, uint256 id, uint256 amount, bytes memory data)
//         public
//         onlyOwner
//     {
//         _mint(account, id, amount, data);
//     }

//     // Function to mint multiple new tokens
//     function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
//         public
//         onlyOwner
//     {
//         _mintBatch(to, ids, amounts, data);
//     }
// }

pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {orderTypes} from "./libraries/orderTypes.sol";

error ZeroAddress();
error InvalidSignature();
error UnAuthorized();
error ZeroQuantity();

contract MyToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable, EIP712Upgradeable{
    
    //event type mint
    event MintedtoUser(address userAddress,uint256 amount,uint256 tokenId);

    /**
     * Using the rewardTypes library for the claimAmount struct.
     * Declares an event for ClaimAmount.
    */
    using orderTypes for orderTypes.OrderItem;

    // mapping(address => mapping(uint256 => bool)) private _isUserClaimNonceExecuted;

    
    // Mapping from token ID to its custom URI
    mapping(uint256 => string) private _tokenURIs;

    // Initialize function instead of constructor
    function initialize(address initialOwner) public initializer {
        __ERC1155_init("");
        __EIP712_init("Marketplace", "1");
        OwnableUpgradeable.__Ownable_init(initialOwner);
        OwnableUpgradeable.transferOwnership(initialOwner);
    }

    // Function to set the URI for a specific token ID
    function setURI(uint256 tokenId, string memory newuri) public onlyOwner {
        _tokenURIs[tokenId] = newuri;
    }

    // Override the uri function to return the custom URI for each token ID
    function uri(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // Function to mint a new token
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintOnSignature(orderTypes.OrderItem calldata OrderData,address user)public{
        if(msg.sender==address(0)){
            revert ZeroAddress();
        }
        bool isVerified;
        isVerified=executeIfSignatureMatch(OrderData);
        if(!isVerified){
            revert InvalidSignature();
        }
        if(!(OrderData.nft_Buyer==user)){
            revert UnAuthorized();
        }
         if(!(OrderData.nft_Buyer==address(0))){
            revert ZeroAddress();
        }
         if(!(OrderData.nft_Buyer==address(0))){
            revert ZeroAddress();
        }

        _mint(OrderData.nft_Buyer, OrderData.tokenId, OrderData.quantity,OrderData.data);
        
        emit MintedtoUser(OrderData.nft_Buyer, OrderData.quantity, OrderData.tokenId);
    }
    // Function to mint multiple new tokens
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function executeIfSignatureMatch
    (orderTypes.OrderItem calldata orderItem)
    internal view returns(bool){
      bytes32 eip712DomainHash=domainHash();
      bytes32 hashStruct;
      hashStruct=generateHashForOrder(
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
      address signer=ecrecover(hash,orderItem.v,orderItem.r,orderItem.s);

      if(!(signer==orderItem.nft_Owner)){
        revert InvalidSignature();
      }
    
      if(signer==address(0)){
        revert InvalidSignature();
      }

      return true;
    }

    function domainHash() internal view returns(bytes32){
        bytes32 hash=keccak256(
          abi.encode(
            keccak256( "EIP712Domain(string name,string version,address verifyingContract)"),
          keccak256(bytes("Marketplace")),
          keccak256(bytes("1")),
          address(this)
        ));
        return hash;
    }
//         address nft_Owner;
//         address nft_Buyer;
//         uint256 tokenId;
//         uint256 quantity;        
//         bytes data;
//         uint256 nonce;
//         uint8 v;
//         bytes32 r;
//         bytes s;

    function generateHashForOrder(
        address _owner,
        address _buyer,
        uint256 _tokenId,
        uint256 _quantity,
        bytes memory _data,
        uint256 _nonce 
        ) 
    internal pure returns(bytes32)
    {
        bytes32 hashStruct=keccak256(
            abi.encode(keccak256("OrderItem(address nft_Owner,address nft_Buyer,uint256 tokenId,uint256 quantity,bytes data,uint256 nonce)"),
            _owner,
            _buyer,
            _tokenId,
            _quantity,
            _data,
            _nonce
            )
        );
        return hashStruct;
    }
}
