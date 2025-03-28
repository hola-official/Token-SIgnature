// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import Foundry's Test library and OpenZeppelin's contracts
import "forge-std/Test.sol";
import "../src/TokenSig.sol";

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
        owner = vm.addr(ownerPrivateKey); // Derive the owner's address
        user1 = address(0x1); // A user who will receive tokens
        user2 = address(0x2); // Another user for testing

        // Deploy the TOKENSIGNER contract
        vm.prank(owner); // Set the msg.sender as the owner for deployment
        token = new TOKENSIGNER(); // Note: ERC20 constructor requires name and symbol, adjust if needed
    }

    // Helper function to generate a signature for the (address, amount) pair
    function signMessage(address _address, uint256 _amount, uint256 _privateKey) internal view returns (bytes memory) {
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

    // Test successful minting with a valid signature
    function testMintWithValidSignature() public {
        uint256 amount = 1000 * 10**18; // 1000 tokens (assuming 18 decimals)
        // Generate a valid signature from the owner
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        // Call mintWithSignature as user1
        vm.prank(user1);
        token.mintWithSignature(user1, amount, signature);

        // Verify the balance of user1
        assertEq(token.balanceOf(user1), amount, "User1 should have the minted tokens");
    }

    // Test minting with an invalid signature (wrong signer)
    function testFailMintWithInvalidSignature() public {
        uint256 amount = 1000 * 10**18;
        // Generate a signature with a different private key (not the owner)
        uint256 wrongPrivateKey = 0xB0B; // A different private key
        bytes memory invalidSignature = signMessage(user1, amount, wrongPrivateKey);

        // Expect the transaction to revert with "NOMINT"
        vm.prank(user1);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user1, amount, invalidSignature);
    }

    // Test minting with a signature for a different address
    function testFailMintWithWrongAddress() public {
        uint256 amount = 1000 * 10**18;
        // Generate a valid signature for user1
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        // Try to mint for user2 using user1's signature
        vm.prank(user2);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user2, amount, signature);
    }

    // Test minting with a signature for a different amount
    function testFailMintWithWrongAmount() public {
        uint256 amount = 1000 * 10**18;
        // Generate a valid signature for a specific amount
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        // Try to mint a different amount using the same signature
        uint256 wrongAmount = 2000 * 10**18;
        vm.prank(user1);
        vm.expectRevert("NOMINT");
        token.mintWithSignature(user1, wrongAmount, signature);
    }

    // Test that the total supply updates correctly after minting
    function testTotalSupplyAfterMint() public {
        uint256 amount = 1000 * 10**18;
        bytes memory signature = signMessage(user1, amount, ownerPrivateKey);

        // Mint tokens
        vm.prank(user1);
        token.mintWithSignature(user1, amount, signature);

        // Verify the total supply
        assertEq(token.totalSupply(), amount, "Total supply should equal the minted amount");
    }
}