// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Import Foundry's testing framework.
//
// Test is a contract provided by forge-std that gives us
// useful testing functionality such as assertEq().
import {Test} from "forge-std/Test.sol";

// Import the smart contract we want to test.
import {CommunityToken} from "../src/CommunityToken.sol";

contract CommunityTokenTest is Test {
    // =============================================================
    // Constants
    // =============================================================
    uint256 public constant ONE_TOKEN = 10 ** 18;
    uint256 public constant MINT_AMOUNT = 500 * ONE_TOKEN;
    uint256 public constant TRANSFER_AMOUNT = 100 * ONE_TOKEN;
    uint256 public constant BURN_AMOUNT = 200 * ONE_TOKEN;

    address public constant ALICE = address(2);
    address public constant BOB = address(3);

    // =============================================================
    // State variables
    // =============================================================
    // This will hold an instance of our CommunityToken contract.
    CommunityToken public token;

    // This represents the account that will deploy our token.
    address public owner;

    // =============================================================
    // Setup - setUp() runs before every test function.
    // =============================================================
    // This is similar to preparing the environment before running an individual test.
    function setUp() public {
        // Create a test address.
        owner = address(1);

        // Make Foundry treat this address as the caller
        // for the next transaction.
        vm.prank(owner);

        // Deploy our CommunityToken contract.
        token = new CommunityToken();
    }

    // =============================================================
    // Deployment and metadata
    // =============================================================
    // Test that the initial supply belongs to the deployer.
    function testInitialSupplyBelongsToOwner() public view {
        // Check that the owner's balance equals the
        // initial supply defined by our contract.
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY());
    }

    function testTokenMetadata() public view {
        assertEq(token.name(), "Community Token");
        assertEq(token.symbol(), "CMT");
        assertEq(token.decimals(), 18);
    }

    // =============================================================
    // Transfers
    // =============================================================
    function testTransfer() public {
        // Pretend the owner is calling token.transfer().
        vm.prank(owner);

        // Transfer 100 CMT from the owner to Alice.
        //
        // The token was deployed while owner was msg.sender,
        // so owner became the contract owner.

        // Expect this transfer to succeed, and I want my test to verify that the function returned true.
        bool isSuccessful = token.transfer(ALICE, TRANSFER_AMOUNT);
        assertTrue(isSuccessful);

        // Verify that Alice received 100 CMT.
        assertEq(token.balanceOf(ALICE), TRANSFER_AMOUNT);

        // Verify that the owner's balance decreased accordingly.
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY() - TRANSFER_AMOUNT);
    }

    function testTransferFailsWhenPaused() public {
        vm.prank(owner);
        token.pause();

        assertTrue(token.paused());

        vm.expectRevert();
        vm.prank(owner);
        token.transfer(ALICE, TRANSFER_AMOUNT);

        // Verify that the balances remain unchanged after the failed transfer
        // Because a reverted transaction rolls back its state changes, Alice should receive nothing and the owner’s balance should remain unchanged
        assertEq(token.balanceOf(ALICE), 0);
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY());
    }

    // Demonstrates using vm.startPrank() and vm.stopPrank() for multiple calls from the same address.
    function testTransferSucceedsAfterUnpausing() public {
        // From this point forward, contract calls will appear
        // to come from the owner.
        vm.startPrank(owner);

        // Owner pauses the token.
        token.pause();

        // Verify that the token is now paused.
        assertTrue(token.paused());

        // Owner unpauses the token.
        token.unpause();

        // Verify that the token is no longer paused.
        assertFalse(token.paused());

        // Transfer 100 CMT from the owner to ALICE.
        assertTrue(token.transfer(ALICE, TRANSFER_AMOUNT));

        // Verify that ALICE received 100 CMT.
        assertEq(token.balanceOf(ALICE), TRANSFER_AMOUNT);

        // Verify that the owner's balance decreased by 100 CMT.
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY() - TRANSFER_AMOUNT);

        // Stop the persistent prank.
        // Future contract calls will no longer automatically use owner
        // as msg.sender.
        vm.stopPrank();
    }

    // =============================================================
    // Minting
    // =============================================================
    function testOwnerCanMint() public {
        // Alice is another address in our test environment.
        address alice = ALICE;

        // We want to create 500 new CMT.
        uint256 amount = MINT_AMOUNT;

        // Pretend the owner is calling mint().
        vm.prank(owner);

        // The owner creates 500 CMT and sends them to Alice.
        token.mint(alice, amount);

        // Verify that Alice received the newly minted tokens.
        assertEq(token.balanceOf(alice), amount);

        // Verify that total supply increased.
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY() + amount);
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY());
    }

    function testNonOwnerCannotMint() public {
        // Alice is NOT the owner.
        address alice = ALICE;

        // We expect the transaction to fail.
        vm.expectRevert();

        // Pretend Alice is calling mint().
        vm.prank(alice);

        // Alice attempts to create 500 CMT.
        token.mint(alice, MINT_AMOUNT);
    }

    function testNonOwnerCannotMintToAnotherAddress() public {
        vm.expectRevert();
        vm.prank(ALICE);
        token.mint(BOB, MINT_AMOUNT);

        assertEq(token.balanceOf(BOB), 0);
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY());
    }

    function testMintToZeroAddressFails() public {
        vm.expectRevert();
        vm.prank(owner);
        token.mint(address(0), MINT_AMOUNT);
    }

    // =============================================================
    // Pausing
    // =============================================================
    function testOwnerCanPause() public {
        // The owner is allowed to call pause().
        vm.prank(owner);
        token.pause();

        // Verify that the token is now paused.
        assertTrue(token.paused());
    }

    function testNonOwnerCannotPause() public {
        address alice = ALICE;

        // Alice is not the owner, so we expect a revert.
        vm.expectRevert();

        // Pretend Alice is calling pause().
        vm.prank(alice);
        token.pause();
    }

    function testNonOwnerCannotUnpause() public {
        address alice = ALICE;

        vm.prank(owner);
        token.pause();

        vm.expectRevert();
        vm.prank(alice);
        token.unpause();
    }

    function testMintFailsWhenPaused() public {
        vm.prank(owner);
        token.pause();

        vm.expectRevert();
        vm.prank(owner);
        token.mint(ALICE, MINT_AMOUNT);
    }

    // =============================================================
    // Burning
    // =============================================================
    function testOwnerCanBurn() public {
        vm.prank(owner);

        // Owner burns 200 CMT (BURN_AMOUNT) from their own balance
        token.burn(BURN_AMOUNT);

        // Verify that the owner's balance decreased by BURN_AMOUNT CMT.
        assertEq(token.balanceOf(owner), token.INITIAL_SUPPLY() - BURN_AMOUNT);

        // Verify that total supply also decreased by BURN_AMOUNT CMT.
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY() - BURN_AMOUNT);
    }

    function testAliceCanBurnHerOwnTokens() public {
        address alice = ALICE;
        uint256 amount = MINT_AMOUNT;
        uint256 amountToBurn = BURN_AMOUNT;

        // Owner sends 500 CMT to Alice.
        vm.prank(owner);
        assertTrue(token.transfer(alice, amount));

        // Alice burns 200 CMT from her own balance.
        vm.prank(alice);
        token.burn(amountToBurn);

        // Alice should now have 300 CMT.
        assertEq(token.balanceOf(alice), amount - amountToBurn);

        // Total supply should have decreased by 200 CMT.
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY() - amountToBurn);
    }

    function testBurnFromWithAllowance() public {
        address alice = ALICE;
        address bob = BOB;
        uint256 amount = MINT_AMOUNT;
        uint256 allowance = BURN_AMOUNT;

        // Give Alice 500 CMT.
        vm.prank(owner);
        assertTrue(token.transfer(alice, amount));

        // Have Alice approve Bob to burn 200 CMT.
        vm.prank(alice);
        token.approve(bob, allowance);

        assertEq(token.allowance(ALICE, BOB), allowance);

        // Have Bob burn 200 CMT from Alice.
        vm.prank(bob);
        token.burnFrom(alice, allowance);

        // Verify Alice now has 300 CMT.
        assertEq(token.balanceOf(alice), amount - allowance);

        // Verify total supply decreased by 200 CMT.
        assertEq(token.totalSupply(), token.INITIAL_SUPPLY() - allowance);

        // Bob's allowance to burn from Alice should now be 0.
        assertEq(token.allowance(alice, bob), 0);

        // Have Bob attempt to burn 500 CMT from Alice.
        vm.expectRevert();

        // We expect the transaction to fail as Bob has no remaining allowance to burn from Alice.
        vm.prank(bob);
        token.burnFrom(alice, MINT_AMOUNT);
    }

    function testBurnMoreThanBalanceFails() public {
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 amountToBurn = ownerBalanceBefore + 1;

        assertEq(ownerBalanceBefore, token.INITIAL_SUPPLY());

        vm.expectRevert();
        vm.prank(owner);
        token.burn(amountToBurn);

        // A reverted transaction must not change token state.
        assertEq(token.balanceOf(owner), ownerBalanceBefore);
        assertEq(token.totalSupply(), totalSupplyBefore);
    }

    function testBurnFailsWhenPaused() public {
        vm.prank(owner);
        token.pause();

        vm.expectRevert();
        vm.prank(owner);
        token.burn(TRANSFER_AMOUNT);
    }
}