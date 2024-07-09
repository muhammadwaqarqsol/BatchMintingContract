// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library orderTypes {

    struct OrderItem{
        // address nft_Owner;
        // address nft_Buyer;
        uint256 tokenId;
        uint256 quantity;        
        bytes data;
        uint256 nonce;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

}