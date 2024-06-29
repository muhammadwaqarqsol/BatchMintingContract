// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import {Test, console} from "lib/forge-std/src/Test.sol";
import {MyToken} from "../src/NFT.sol";

contract NFT_Test is Test {
  MyToken public nft_contract;

   //key creation for nft creator {user : nft creator}
    uint256 internal creatorPrivateKey;
    address internal creator;


  function setUp() public{

        //maker private key
        creatorPrivateKey = 0xA11CE;
        //maker public address
        creator = vm.addr(creatorPrivateKey);
        vm.startPrank(creator);        

        nft_contract = new MyToken();

        //initialize the nft contract
        nft_contract.initialize(creator);
        vm.stopPrank();
    }


        /**
     * @notice create new nft as creator
     * Function be able to create a new nft
     */
    //creating an NFT testing nft contract function
    function test_createNFT() public{
      vm.startPrank(creator);
        nft_contract.setURI(1,"ABC");
        nft_contract.setURI(2,"DEF");
        assertEq(nft_contract.uri(1),"ABC");
        assertEq(nft_contract.uri(2),"DEF");
        vm.stopPrank();
    }


}
