// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFT  is ERC1155Upgradeable{
    // Mapping from token ID to its custom URI
    mapping(uint256 => string) private _tokenURIs;


        // Initialize function instead of constructor
    function initialize() public initializer {
        ERC1155Upgradeable.__ERC1155_init("");
    }

    // Override the uri function to return the custom URI for each token ID
    function uri(uint256 tokenId) public view override 
    returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // Function to mint to an address and transfer to another address
    function mintAndTransfer(
        address _creator,
        address _to,
        uint256 id,
        uint256 amount,
        string memory _tokenURI,
        bytes memory data
    ) external {
        require(_creator != address(0),"Has zero Address");
        require(_to != address(0), "Have zero Address");
        require(_creator != _to, "Have same address");

        // Mint the tokens to the 'from' address
        _mint(_creator, id, amount, data);

        // Set the URI for the token ID
        _tokenURIs[id] = _tokenURI;

        // Transfer the tokens from 'from' to the 'to' address
        _safeTransferFrom(_creator, _to, id, amount, data);
    }
}