// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {orderTypes} from "./libraries/orderTypes.sol";
contract NFTMarket  is ERC1155Upgradeable{
      // Mapping from token ID to its custom URI
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public _totalmintedProduct;


        // Initialize function instead of constructor
    function initialize() public initializer {
        ERC1155Upgradeable.__ERC1155_init("");
    }

    // Override the uri function to return the custom URI for each token ID
    function uri(uint256 tokenId) public view override 
    returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // Function to mint to msg.sender and transfer to another address
    function mintAndTransfer(uint256 id, uint256 amount, 
    string memory newuri, bytes memory data, address _to,
    address _creator) public {
       require(_creator != address(0),"Has Zero Address");
       require(_to != _creator,"Have same Address");
        // Mint the tokens to msg.sender
        _tokenURIs[id] = newuri;
        _mint(msg.sender, id, amount, data);
        // Transfer the tokens from msg.sender to the specified address
        safeTransferFrom(msg.sender, _to, id, amount, data);
    }
}