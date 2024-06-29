// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
// import "@openzeppelin/contracts-upgradeable/contracts/token/ERC1155/ERC1155Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
contract MyToken is Initializable, ERC1155Upgradeable, OwnableUpgradeable {
    // Mapping from token ID to its custom URI
    mapping(uint256 => string) private _tokenURIs;

    // Initialize function instead of constructor
    function initialize(address initialOwner) public initializer {
        __ERC1155_init("");
        __Ownable_init(msg.sender);
        transferOwnership(initialOwner);
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

    // Function to mint multiple new tokens
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
}
