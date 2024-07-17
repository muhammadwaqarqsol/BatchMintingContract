// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "src/NFT.sol";
import "src/NFTMarket.sol";
import "src/USDT.sol";
import "src/libraries/OrderTypes.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFT_TEST is Test{
      //order type for nfts
    using OrderTypes for OrderTypes.LazyMakeOrder;
    using OrderTypes for OrderTypes.LazyTakerOrder;

    //contract addresses
    NFTMarket public _marketContract;
    NFT public nft_contract;
    USDTToken public usdt_contract;

    //key creation for nft creator {user : nft creator}
    uint256 internal creatorPrivateKey;
    address internal creator;

    //key creation for nft creator {user : third party or not owner}
    uint256 internal thirdpartyPrivateKey;
    address internal thirdparty;

    //key creation for nft creator {user : first buyer / user}
    uint256 internal buyeronePrivateKey;
    address internal buyerone;

    //key creation for nft creator {user : second buyer / user}
    uint256 internal secondBuyerPrivateKey;
    address internal secondBuyer;

    //temperory maker order 
    OrderTypes.LazyMakeOrder public tempMakerOrder;

    //using hash for temp order lazy
    bytes32 public constant Lazy_MakerOrder_TYPEHASH =
        keccak256(
            "LazyListNFT(bool IsOrderAsk,address sender,address collection,address baseAccount,uint price,uint tokenId,uint quantity)"
        );
  /**
     * @notice Setup for testing contract with all the address of nft, nft market and user {fake private key}
     * Function be able to setup all the required stuff.
     */
    function setUp() public {
       //address creation and private key for users

        //maker private key
        creatorPrivateKey = 0xA11CE;
        //maker public address
        creator = vm.addr(creatorPrivateKey);

        //taker private key
        buyeronePrivateKey = 0xB0B;
        //taker public address
        buyerone = vm.addr(buyeronePrivateKey);

        //offer creator private key
        secondBuyerPrivateKey = 0xB0A;
        //public address
        secondBuyer = vm.addr(secondBuyerPrivateKey);

        //contract owner
        thirdpartyPrivateKey=0xB0C;
        //address of owner
        thirdparty=vm.addr(thirdpartyPrivateKey);
        //contract deployment
        
        _marketContract = new NFTMarket();

        nft_contract = new NFT();

        usdt_contract = new USDTToken();

        _marketContract.initialize(address(usdt_contract));
        //initialize the nft contract
        nft_contract.initialize();
    }



    function test_WrongOrder() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(true, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
            bytes4 selector = bytes4(keccak256("WrongOrder()"));
            vm.expectRevert(selector);
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
      }


         function test_WrongOrder_IsOrderAskFalse() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(false,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(true, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
            bytes4 selector = bytes4(keccak256("WrongOrder()"));
            vm.expectRevert(selector);
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
      }

     function test_WrongOrder_SameSigner() public {

          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(false,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(creator);

          usdt_contract.mint(creator, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(true, creator, 3 * (10 ** 6), "Some Uri",3,1);
            bytes4 selector = bytes4(keccak256("WrongOrder()"));
            vm.expectRevert(selector);
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }



      function test_UnAuthorizedBuyer() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(secondBuyer);

          usdt_contract.mint(secondBuyer, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(false, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
             vm.expectRevert(abi.encodeWithSelector(NFTMarket.UnAuthorizedOwner.selector,address(secondBuyer),buyerone));
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }


    function test_SignerAddressToBeZeroAddress() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          address(0),
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(false, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
            vm.expectRevert(abi.encodeWithSelector(NFTMarket.ZeroAddress.selector));
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }



    function test_BaseAccountToBeZeroAddress() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          creator,
          address(0),
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(false, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
            vm.expectRevert(abi.encodeWithSelector(NFTMarket.ZeroAddress.selector));
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }


      function test_InvalidPrice() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(false, buyerone, 1 * (10 ** 6), "Some Uri",3,1);
           vm.expectRevert(abi.encodeWithSelector(NFTMarket.InvalidPrice.selector));
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }


    function test_InvalidSignature() public {
          //creator takes signature for listing
          vm.prank(creator);
          takeSignature(true,
          creator,
          creator,
          address(nft_contract),
          creator,
          1,
          1* 10 ** 6,
          6,
          Lazy_MakerOrder_TYPEHASH,
          creatorPrivateKey);
          vm.stopPrank();

          //buyer comes to mint usdt and approve
          vm.startPrank(buyerone);

          usdt_contract.mint(buyerone, 3);
          usdt_contract.approve(address(_marketContract), 3 * 10 ** 6);


      
          OrderTypes.LazyTakerOrder memory lazytakerOrder = OrderTypes
              .LazyTakerOrder(false, buyerone, 3 * (10 ** 6), "Some Uri",3,1);
            tempMakerOrder.v=1;
          vm.expectRevert(abi.encodeWithSelector(NFTMarket.InValidSignature.selector));
          _marketContract.directLazyMinting(
              lazytakerOrder,
              tempMakerOrder,
              false
          );

          vm.stopPrank();
    }




    function takeSignature(  
        bool isOrderAsk,
        address signer,
        address baseAccount, 
        address nftcontract,
        address accountOwner,
        uint256 tokenId,
        uint256 price,
        uint256 quantity,
        bytes32 orderhash,
        uint256 privatekey)
        public returns( uint8 v,
        bytes32 r,
        bytes32 s)
        {
       
        OrderTypes.LazyMakeOrder memory lazymakeorder=OrderTypes.LazyMakeOrder(
          isOrderAsk,
          signer,
          baseAccount,
          nftcontract,
          accountOwner,
          tokenId,
          price,
          quantity,
            0,
            0x00,
            0x00
         );

      bytes32 digest=getTypedDataHash(lazymakeorder,orderhash);
      (v,r,s)=vm.sign(privatekey,digest);
      lazymakeorder.v=v;
      lazymakeorder.r=r;
      lazymakeorder.s=s;
      tempMakerOrder=lazymakeorder;
    }

    function getTypedDataHash(
        OrderTypes.LazyMakeOrder memory lazyMakeOrder,bytes32 orderhash
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainHash(),
                    getStructHash(lazyMakeOrder,orderhash)
                )
            );
    }

    
     function domainHash() internal view returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,address verifyingContract)"
                ),
                keccak256(bytes("MarketPlace")),
                keccak256(bytes("1")),
                address(_marketContract)
            )
        );
        return hash;
    }

  
    function getStructHash(
        OrderTypes.LazyMakeOrder memory lazymakeorder,bytes32 orderhash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    orderhash,
                    lazymakeorder.isOrderAsk,
                    lazymakeorder.signer,
                    lazymakeorder.nftContract,
                    lazymakeorder.baseAccount,
                    lazymakeorder.price,
                    lazymakeorder.tokenId,
                    lazymakeorder.quantity
                )
            );
    }
}

