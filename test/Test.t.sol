// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/testing/TestingSignature.sol";
import "../src/libraries/orderTypes.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    address public owner;
    address public user;
    orderTypes.OrderItem public orderItem;

    function setUp() public {
        owner = address(this);
        user = address(0x1234);
        myToken = new MyToken();
        myToken.initialize(owner);

        // Set up a valid order item
        orderItem = orderTypes.OrderItem({
            nft_Owner: owner,
            nft_Buyer: user,
            tokenId: 1,
            quantity: 10,
            data: "",
            nonce: 1,
            v: 0,
            r: 0,
            s: 0
        });

        // Simulate signing the order item
        bytes32 orderHash = generateHashForOrder(
            orderItem.nft_Owner,
            orderItem.nft_Buyer,
            orderItem.tokenId,
            orderItem.quantity,
            orderItem.data,
            orderItem.nonce
        );
        bytes32 domainSeparator = domainHash();
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, orderHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(uint256(uint160(owner)), digest);
        orderItem.v = v;
        orderItem.r = r;
        orderItem.s = s;
    }

    function testInitialize() public {
        assertEq(myToken.owner(), owner);
    }

    function testMintWithSignature() public {
        // Ensure initial balance is zero
        assertEq(myToken.balanceOf(user, orderItem.tokenId), 0);

        // Mint with valid signature
        myToken.mintWithSignature(orderItem);

        // Verify balance after minting
        assertEq(myToken.balanceOf(user, orderItem.tokenId), orderItem.quantity);

        // Attempt to mint again with the same nonce (should fail)
        vm.expectRevert("AlreadyExecuted");
        myToken.mintWithSignature(orderItem);
    }

    function testMintWithInvalidSignature() public {
        // Modify orderItem to have an invalid signature
        orderItem.nonce = 2;

        // Attempt to mint with invalid signature (should fail)
        vm.expectRevert("Invalid signature");
        myToken.mintWithSignature(orderItem);
    }

    function generateHashForOrder(
        address _owner,
        address _buyer,
        uint256 _tokenId,
        uint256 _quantity,
        bytes memory _data,
        uint256 _nonce
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                keccak256("OrderItem(address nft_Owner,address nft_Buyer,uint256 tokenId,uint256 quantity,bytes data,uint256 nonce)"),
                _owner,
                _buyer,
                _tokenId,
                _quantity,
                _data,
                _nonce
            )
        );
    }

    function domainHash() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,address verifyingContract)"),
                keccak256(bytes("Marketplace")),
                keccak256(bytes("1")),
                address(this)
            )
        );
    }
}