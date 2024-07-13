// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./NFT.sol";
import {OrderTypes} from "./libraries/OrderTypes.sol";


contract NFTMarket is
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    OwnableUpgradeable,
    EIP712Upgradeable
{
   //Order Types
    using OrderTypes for OrderTypes.LazyMakeOrder;
    using OrderTypes for OrderTypes.LazyTakerOrder;

   //NFT contract 
   NFT private tokenNft;
  
  //customo actions
    enum Action {
        BUY
    }
    //usdt contract address
    address usdtAddress;
    IERC20 usdtToken;


  function initialize(address token)public initializer {
      __EIP712_init("Marketplace", "1");
       usdtToken = IERC20(token);
       OwnableUpgradeable.__Ownable_init(msg.sender);
      ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
  }

    // Custom Error for call revert
    error InvalidPrice();
    error UnAuthorized();
    error UnAuthorizedApproval();
    error UnAuthorizedOwner(address available, address required);
    error WrongOrder();
    error InValidTokenId();
    error ZeroAddress();
    error InValidSignature();
    error InSufficientAllowance(uint256 available, uint256 required);
    error Failed();
    error OrderExectued();
    error InvalidOwner();


    // Event of TransferNft
    event TransferNft(
          address nftContract,
          address from,
          address to,
          uint256 indexed tokenId,
          uint256 price,
          uint256 Quantity
      );
    

    //mapping to check how much listed item sold
    mapping(uint256 => uint256) private _SoldItemsCount;


    function directLazyMinting(
        OrderTypes.LazyTakerOrder calldata takerBid,
        OrderTypes.LazyMakeOrder calldata makerAsk,
        bool _isAbstraction
    )public payable{
        // Check if the maker's order has already been executed.
        tokenNft = NFT(makerAsk.nftContract);
         // Verify that the order types are correct (maker's ask and taker's bid).
        if (makerAsk.signer == takerBid.taker) {
            revert WrongOrder();
        }

        // Verify that the order types are correct (maker's ask and taker's bid).
        if (!(makerAsk.isOrderAsk && !takerBid.isOrderAsk)) {
            revert WrongOrder();
        }

        // Check that the caller is the owner of the taker order.
        if (!(msg.sender == takerBid.taker || msg.sender == owner())) {
            revert UnAuthorizedOwner({
                available: msg.sender,
                required: takerBid.taker
            });
        }

         // Check that the maker's signer and base account addresses are not null.
        if (
            makerAsk.signer == address(0) || makerAsk.baseAccount == address(0)
        ) {
            revert ZeroAddress();
        }


         // Check if the price matches the expected price per NFT multiplied by quantity.
        if (takerBid.price != makerAsk.price * takerBid.quantity) {
            revert InvalidPrice();
        }
         // Verify that the allowance meets the maker's asking price.
        hasAllowance(msg.sender, (makerAsk.price));


        bool isVerified;

        if (_isAbstraction) {
            isVerified = executeIfLazyAASignatureMatch(
                makerAsk,
                uint8(Action.BUY)
            );
        } else {
            // Verify the maker's signature using the provided parameters.
            isVerified = executeIfLazySignatureMatch(
                makerAsk,
                uint8(Action.BUY)
            );
        }
    }



  function executeIfLazySignatureMatch(
        OrderTypes.LazyMakeOrder calldata maker,
        uint8 actionChoice
    ) internal view returns (bool) {
        // Calculate the EIP712 domain hash
        bytes32 eip712DomainHash = domainHash();
        bytes32 
            // Generate the hash for a buy order
            hashStruct = generateHashForLazyBuy(
                maker.signer,
                maker.nftContract,
                maker.baseAccount,
                maker.,
                maker.nonce,
                maker.price
            );
    
        // Calculate the final hash by combining the EIP712 domain hash and the struct hash
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct)
        );

        // Recover the signer address from the hash and signature components
        address signer = ecrecover(hash, maker.v, maker.r, maker.s);

        // Check if the recovered signer matches the expected signer address
        if (!(signer == maker.signer)) {
            revert InValidSignature();
        }

        // Check if the signer address is not zero
        if (signer == address(0)) {
            revert InValidSignature();
        }

        return true;
    }

    function executeIfLazyAASignatureMatch(
        OrderTypes.LazyMakeOrder calldata maker,
        uint8 actionChoice
    ) internal view returns (bool) {
        bytes32 hashStruct = keccak256(
                abi.encode(
                    keccak256(
                        "AALazyListNFT(bool IsOrderAsk,address sender,address collection,address baseAccount,uint price,uint quantity)"
                    ),
                    true,
                    maker.signer,
                    maker.nftContract,
                    maker.baseAccount,
                    maker.price,
                    maker.quantity
                )
            );
       
        // bytes32 structHash = keccak256(abi.encode(_MESSAGE_TYPEHASH,true,signer1,collection));
        bytes32 hash = _hashTypedDataV4(hashStruct);
        address signer = ecrecover(hash, maker.v, maker.r, maker.s);

        // Check if the recovered signer matches the expected signer address
        if (!(signer == maker.accountOwner)) {
            revert InValidSignature();
        }

        // Check if the signer address is not zero
        if (signer == address(0)) {
            revert InValidSignature();
        }

        return true;
    }

    function generateHashForLazyBuy(
        address sender,
        address _nftContract,
        address _baseAccount,
        address _nftOwner,
        uint _price,
        uint _quantity
    ) internal pure returns (bytes32) {
        // Create a hash for the struct using the ABI-encoded parameters
        bytes32 hashStruct = keccak256(
            abi.encode(
                keccak256(
                      "LazyListNFT(bool IsOrderAsk,address sender,address collection,address baseAccount,uint price,uint quantity)"
                ),
                true,
                sender,
                _nftContract,
                _baseAccount,
                _nftOwner,
                _price,
                _quantity
            )
        );

        return hashStruct;
    }

    
    function domainHash() internal view returns (bytes32) {
        // Encode the EIP-712 domain separator struct definition
        bytes32 hash = keccak256(
            abi.encode(
                // First, we encode the EIP-712 domain separator struct definition
                keccak256(
                    "EIP712Domain(string name,string version,address verifyingContract)"
                ),
                keccak256(bytes("MarketPlace")), // Name of the domain
                keccak256(bytes("1")), // Version of the domain
                address(this) // Address of the verifying contract
            )
        );
        // Return the resulting hash value
        return hash;
    }

    function hasAllowance(
        address _approval,
        uint _amount
    ) internal view {
        if (msg.sender == owner()){
            _approval = msg.sender;
        }
        if (_amount > usdtToken.allowance(_approval,address(this))) {
            revert InSufficientAllowance({
                available: usdtToken.allowance(_approval, address(this)),
                required: _amount
            });
        }
    }
}