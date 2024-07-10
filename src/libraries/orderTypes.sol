// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library orderTypes {

    struct OrderItem{
        address nft_Owner;
        address nft_Buyer;
        uint256 tokenId;
        uint256 quantity;        
        bytes data;
        uint256 nonce;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

      struct LazyMakeOrder {
        bool isOrderAsk; // true --> ask / false --> bid
        address signer; // signer of the maker order
        address baseAccount; // address for the payment
        address nftContract; // collection address
        address nftOwner;
        address accountOwner;
        uint256 price; // price (used as )
        // uint256 tokenId; // id of the token
        uint256 tax; // service fee for the owner of contract
        // uint256 royalty; // royalty amount sent to creator
        uint256 nonce; // order nonce (must be unique unless new maker order is meant to override existing one e.g., lower ask price)
        uint8 v; // v: parameter (27 or 28)
        bytes32 r; // r: parameter
        bytes32 s; // s: parameter
    }

    struct LazyTakerOrder {
        bool isOrderAsk; // true --> ask / false --> bid
        address taker; // msg.sender
        uint256 price; // final price for the purchase + tax
        string  uri;//uri for token
    }

}