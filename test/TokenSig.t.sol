// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSig.sol"; // Adjust the path based on your project structure

contract TOKENSIGNERTest is Test {
    TOKENSIGNER token;
    address owner;
    address user1;
    address user2;
    uint256 ownerPrivateKey;

    // Set up the test environment
    function setUp() public {
        // Generate addresses and private keys for testing
        ownerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        owner = vm.addr(ownerPrivateKey);
        user1 = address(0x1);
        user2 = address(0x2);

        // Deploy the TOKENSIGNER contract
        vm.prank(owner);
        token = new TOKENSIGNER();
    }

    // Helper function to generate a signature for the (address, amount) pair
    function signMessage(address _address, uint256 _amount, uint256 _privateKey) internal pure returns (bytes memory) {
        // Create the hash of the address and amount
        bytes32 messageHash = keccak256(abi.encodePacked(_address, _amount));
        // Add the Ethereum signed message prefix
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        // Sign the message using the private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_privateKey, ethSignedMessageHash);
        // Return the signature as a single bytes array
        return abi.encodePacked(r, s, v);
    }

    function test_InitialState() public view {
        assertEq(token.name(), "TokenSig", "Token name should be TokenSig");
        assertEq(token.symbol(), "TSIG", "Token symbol should be TSIG");
        assertEq(token.owner(), owner, "Owner should be set correctly");
        assertEq(token.totalSupply(), 0, "Initial supply should be 0");
    }

    function test_MintWithValidSignature() public {
        uint256 amount = 1000 * 10**18;
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        vm.prank(user1);
        token.mintWithSignature(user1, amount, signature);

        assertEq(token.balanceOf(user1), amount, "User1 should have the minted tokens");
        assertEq(token.totalSupply(), amount, "Total supply should be updated");
    }

    function test_MintMultipleTimes() public {
        uint256 amount1 = 1000 * 10**18;
        uint256 amount2 = 2000 * 10**18;
        
        bytes memory signature1 = signMessage(user1, amount1, ownerPrivateKey);
        bytes memory signature2 = signMessage(user1, amount2, ownerPrivateKey);

        vm.prank(user1);
        token.mintWithSignature(user1, amount1, signature1);
        
        vm.prank(user1);
        token.mintWithSignature(user1, amount2, signature2);

        assertEq(token.balanceOf(user1), amount1 + amount2, "User1 should have both amounts");
        assertEq(token.totalSupply(), amount1 + amount2, "Total supply should be updated");
    }

    function test_MintToDifferentUsers() public {
        uint256 amount1 = 1000 * 10**18;
        uint256 amount2 = 2000 * 10**18;
        
        bytes memory signature1 = signMessage(user1, amount1, ownerPrivateKey);
        bytes memory signature2 = signMessage(user2, amount2, ownerPrivateKey);

        vm.prank(user1);
        token.mintWithSignature(user1, amount1, signature1);
        
        vm.prank(user2);
        token.mintWithSignature(user2, amount2, signature2);

        assertEq(token.balanceOf(user1), amount1, "User1 should have correct amount");
        assertEq(token.balanceOf(user2), amount2, "User2 should have correct amount");
        assertEq(token.totalSupply(), amount1 + amount2, "Total supply should be updated");
    }

    function test_RevertWhen_InvalidSignature() public {
        uint256 amount = 1000 * 10**18;
        uint256 wrongPrivateKey = 0xB0B;
        bytes memory invalidSignature = signMessage(user1, amount, wrongPrivateKey);

        vm.prank(user1);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user1, amount, invalidSignature);
    }

    function test_RevertWhen_WrongAddress() public {
        uint256 amount = 1000 * 10**18;
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        vm.prank(user2);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user2, amount, signature);
    }

    function test_RevertWhen_WrongAmount() public {
        uint256 amount = 1000 * 10**18;
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        uint256 wrongAmount = 2000 * 10**18;
        vm.prank(user1);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user1, wrongAmount, signature);
    }

    function test_RevertWhen_EmptySignature() public {
        uint256 amount = 1000 * 10**18;
        bytes memory emptySignature = "";

        vm.prank(user1);
        vm.expectRevert();
        token.mintWithSignature(user1, amount, emptySignature);
    }
}