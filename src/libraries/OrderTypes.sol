// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library OrderTypes {

    struct LazyMakeOrder {
        bool isOrderAsk; // true --> ask / false --> bid
        address signer; // signer of the maker order
        address baseAccount; // address for the payment
        address nftContract; // collection address
        address accountOwner;
        address nftOwner;
        uint256 tokenId; // id of the token
        uint256 price; // price (used as )
        uint256 quantity;
        uint8 v; // v: parameter (27 or 28)
        bytes32 r; // r: parameter
        bytes32 s; // s: parameter
    }

    struct LazyTakerOrder {
        bool isOrderAsk; // true --> ask / false --> bid
        address taker; // msg.sender
        uint256 price; // final price for the purchase + tax
        string  uri;//uri for token
        uint256 quantity;
        uint256 tokenId; // tokenId of NFT
    }

}