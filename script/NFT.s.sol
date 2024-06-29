// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;
// import {NFT} from "../src/NFT.sol";
// import {Script, console} 
// from "lib/forge-std/src/Script.sol";
// contract NFTScript is Script {
//     function setUp() public {}
        
//     NFT public nft_contract;
//     function run() public {
//         uint privatekey=vm.envUint("DEV_PRIVATE_KEY");
//         address account=vm.addr(privatekey);
//         console.log(account);
//         vm.startBroadcast(vm.addr(privatekey));
//         //deploy contract
//         nft_contract = new NFT();

//         //initialize the nft contract
//         nft_contract.initialize("Xolton Tokens", "XTK");

//         //mint token 
//         nft_contract.createToken("new token");
//         vm.stopBroadcast();
//     }
// }
