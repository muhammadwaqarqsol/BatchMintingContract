// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {orderTypes} from "../libraries/orderTypes.sol";
error onlyProductOwner();
error ExceedsAvailableProduct(uint256 available);
error TransfersNotAllowed();
contract MyToken is ERC1155Upgradeable, OwnableUpgradeable, EIP712Upgradeable{
    //total quanity for a single product
    mapping (uint256 => uint256) public total_available_product;
    
    // owner of the product
    // mapping(uint256=>address) public owner_of_product;
    
    // Mapping from token ID to its custom URI
    mapping(uint256 => string) private _tokenURIs;

    // Initialize function instead of constructor
    function initialize(address initialOwner) public initializer {
        __ERC1155_init("");
        __Ownable_init(initialOwner);
        transferOwnership(initialOwner);
    }

    // Function to set the URI for a specific token ID
    function setURI(uint256 tokenId, string memory newuri,uint256 total_prouct) public{
        _tokenURIs[tokenId] = newuri;
        // owner_of_product[tokenId]=msg.sender;
        total_available_product[tokenId]=total_prouct;
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
        uint256 available = total_available_product[id];
        if (amount > available) {
            revert ExceedsAvailableProduct(available);
        }
        total_available_product[id] -= amount;
        _mint(account, id, amount, data);

    }
       // Override _beforeTokenTransfer to block transfers
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual override {
        // Block transfers by reverting if both from and to are not zero addresses
        if (from != address(0) && to != address(0)) {
            revert TransfersNotAllowed();
        }

        // Call the original _update function if needed
        super._update(from, to, ids, values);
    }



    // Function to mint multiple new tokens
    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    //     onlyOwner
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }

}
