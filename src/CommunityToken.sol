// SPDX-License-Identifier: MIT
// SPDX is a standard way of declaring the license for this source code.

pragma solidity ^0.8.24;
// Tells the Solidity compiler which language version this contract
// is compatible with.
//
// Our Foundry configuration is currently compiling with Solidity 0.8.35,
// which satisfies ^0.8.24.

// ---------------------------------------------------------------
// OpenZeppelin imports
// ---------------------------------------------------------------

// ERC20 provides the standard functionality required by an ERC-20 token.
//
// Among other things, it provides functions such as:
// - transfer()
// - approve()
// - transferFrom()
// - balanceOf()
// - totalSupply()
// - allowance()
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20Burnable adds the ability for token holders to destroy (burn)
// their own tokens.
//
// We don't implement burn() ourselves because this inherited contract
// already provides the functionality.
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// ERC20Pausable provides functionality for temporarily stopping token
// transfers.
//
// We will expose pause() and unpause() functions below.
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

// Ownable provides basic ownership/access-control functionality.
//
// It gives the contract an "owner" and provides the onlyOwner modifier,
// which we will use to restrict certain functions.
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// ---------------------------------------------------------------
// CommunityToken contract
// ---------------------------------------------------------------

// Our CommunityToken inherits functionality from four OpenZeppelin
// contracts:
//
// ERC20
//     Standard ERC-20 token functionality.
//
// ERC20Burnable
//     Allows users to burn their own tokens.
//
// ERC20Pausable
//     Provides functionality to pause token transfers.
//
// Ownable
//     Provides an owner and the onlyOwner access-control modifier.
//
// Because of inheritance, we don't need to rewrite all of the
// ERC-20 functionality ourselves.
contract CommunityToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {

    // -----------------------------------------------------------
    // Token configuration
    // -----------------------------------------------------------

    // The initial token supply will be 1,000,000 CMT.
    //
    // ERC-20 tokens normally use 18 decimal places.
    //
    // Therefore:
    //
    // 1 CMT = 1 * 10^18 internal units
    //
    // So 1,000,000 CMT is represented internally as:
    //
    // 1,000,000 * 10^18
    //
    // "constant" means this value cannot be changed after compilation.
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    // -----------------------------------------------------------
    // Constructor
    // -----------------------------------------------------------

    // The constructor runs exactly once: when the CommunityToken contract is deployed.
    constructor()

        // Initialize the ERC20 parent contract.
        //
        // "Community Token" = human-readable token name
        // "CMT"             = token symbol
        ERC20("Community Token", "CMT")

        // Initialize the Ownable parent contract.
        //
        // msg.sender is the address that deployed the contract.
        //
        // Therefore, the person/account that deploys this contract
        // becomes the initial owner.
        // When CommunityToken is deployed, create an ERC-20 token called Community Token with symbol CMT, make the deployer the owner, and give the deployer the initial supply.
        
        /*
        When the contract is deployed, there is a deployer.

        Suppose Alice deploys the contract:
        Alice
        │
        │ deploy
        ▼
        CommunityToken
        During deployment:        msg.sender
        is Alice's address.
        So:
        Ownable(msg.sender)
        effectively means:
        "Make the address that deployed this contract the owner."
        Therefore:
        deployer
        ↓
        msg.sender
        ↓
        owner

        This is why we can later do:

        vm.prank(owner);
        token.mint(...);

        in our tests. 
        */
        Ownable(msg.sender)
    {
        // Create the initial supply and give all of it to the
        // account that deployed the contract.
        //
        // _mint() is provided by OpenZeppelin's ERC20 implementation.
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // -----------------------------------------------------------
    // Minting
    // -----------------------------------------------------------

    // Creates new tokens and sends them to the specified address.
    //
    // "external" means this function is intended to be called from
    // outside the contract.
    //
    // "onlyOwner" means ONLY the contract owner can call this function.
    //
    // Example:
    //
    // mint(0xABC..., 100 * 10^18)
    // would create 100 CMT and give them to 0xABC...

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // -----------------------------------------------------------
    // Pausing
    // -----------------------------------------------------------

    // Pause token transfers.
    //
    // Only the owner can pause the contract.
    function pause() external onlyOwner {
        _pause();
    }

    // Resume token transfers after they have been paused.
    //
    // Only the owner can unpause the contract.
    function unpause() external onlyOwner {
        _unpause();
    }

    // -----------------------------------------------------------
    // ERC20 + ERC20Pausable compatibility
    // -----------------------------------------------------------

    // Both ERC20 and ERC20Pausable have an _update() function.
    //
    // Because our contract inherits from both of them, Solidity
    // requires us to explicitly tell it which implementation should
    // be used.
    //
    // ERC20Pausable uses this hook to prevent transfers while the
    // contract is paused.
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {

        // "super" calls the parent implementation.
        //
        // This allows the ERC20 and ERC20Pausable logic to work
        // together.
        super._update(from, to, value);
    }
}