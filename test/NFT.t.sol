// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.20;

// import {Test, console} from "lib/forge-std/src/Test.sol";
// import {MyToken} from "../src/NFT.sol";

// import "src/libraries/orderTypes.sol";

// contract NFT_Test is Test {
//   using orderTypes for orderTypes.OrderItem;
//   MyToken public nft_contract;

//   //key creation for nft creator {user : nft creator}
//   uint256 internal creatorPrivateKey;
//   address internal creator;

//   //key creation for nft creator {user : first buyer / user}
//   uint256 internal buyeronePrivateKey;
//   address internal buyerone;

//   //temperary maker order
//   orderTypes.OrderItem public tempMakerOrder;


//   bytes32 public constant Order_TypeHash=keccak256(
//     "OrderItem(address nft_Owner,address nft_Buyer,uint256 tokenId,uint256 quantity,bytes data,uint256 nonce)"
//   ) ;

//   function setUp() public{

//         creatorPrivateKey = 0xA11CE;
//         creator = vm.addr(creatorPrivateKey);
//         vm.startPrank(creator);        

//         nft_contract = new MyToken();

//         //initialize the nft contract
//         nft_contract.initialize(creator);
//         vm.stopPrank();


//         buyeronePrivateKey = 0xB0B;
//         buyerone = vm.addr(buyeronePrivateKey);
//     }



//     //creating different product uris and then matching it to check it
//     function test_setNFTURI() public{
//       vm.startPrank(creator);
//         nft_contract.setURI(1,"ABC");
//         nft_contract.setURI(2,"DEF");
//         assertEq(nft_contract.uri(1),"ABC");
//         assertEq(nft_contract.uri(2),"DEF");
//         vm.stopPrank();
//     }


//     /**
//      * @notice create new nft as creator
//      * Function be able to create a new nft
//      */
//     //creating an NFT testing nft contract function
//     function test_createNFT() public{
//       vm.startPrank(creator);
//         nft_contract.setURI(1,"ABC");
//         assertEq(nft_contract.uri(1),"ABC");
//       vm.stopPrank();

//     }



//     function takeSignature(  
//        address nft_Owner,
//         address nft_Buyer,
//         uint256 tokenId,
//         uint256 quantity,        
//         bytes data,
//         uint256 nonce,
//         bytes32 orderhash,
//         uint256 privatekey) public returns( uint8 v,
//         bytes32 r,
//         bytes32 s)
//         {
       
//         orderTypes.OrderItem memory makeorder=orderTypes.OrderItem(
//           nft_Owner,
//           nft_Buyer,
//           tokenId,
//           quantity,
//           data,
//           nonce,
//             0,
//             0x00,
//             0x00
//          );

//       bytes32 digest=getTypedDataHash(makeorder,orderhash);
//       (v,r,s)=vm.sign(privatekey,digest);
//       makeorder.v=v;
//       makeorder.r=r;
//       makeorder.s=s;
//       tempMakerOrder=makeorder;
//     }

//     function getTypedDataHash(
//         orderTypes.OrderItem memory makerorder,bytes32 orderhash
//     ) public view returns (bytes32) {
//         return
//             keccak256(
//                 abi.encodePacked(
//                     "\x19\x01",
//                     domainHash(),
//                     getStructHash(makerorder,orderhash)
//                 )
//             );
//     }

    
//      function domainHash() internal view returns (bytes32) {
//         bytes32 hash = keccak256(
//             abi.encode(
//                 keccak256(
//                     "EIP712Domain(string name,string version,address verifyingContract)"
//                 ),
//                 keccak256(bytes("MarketPlace")),
//                 keccak256(bytes("1")),
//                 address(nft_contract)
//             )
//         );
//         return hash;
//     }

  
//     function getStructHash(
//         orderTypes.OrderItem memory makeorder,bytes32 orderhash
//     ) internal pure returns (bytes32) {
//         return
//             keccak256(
//                 abi.encode(
//                     orderhash,
//                     makeorder.nft_Owner,
//         makeorder.nft_Buyer,
//         makeorder.tokenId,
//         makeorder.quantity,        
//         makeorder.data,
//         makeorder.nonce)
//             );
//     }


// }
