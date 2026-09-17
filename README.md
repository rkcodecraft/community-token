# CommunityToken (CMT)

A Solidity-based ERC-20 community token built with Foundry and OpenZeppelin, featuring owner-controlled minting, token burning, pausing, and access control.

This project is a hands-on implementation focused on understanding ERC-20 tokens, smart-contract ownership, access control, token minting and burning, pausing, allowances, events, contract storage, transaction calldata, and Solidity testing.

The contract was deployed and tested on the Ethereum Sepolia test network.

## Features

- ERC-20 token standard
- Token name: `Community Token`
- Token symbol: `CMT`
- Initial supply: `1,000,000 CMT`
- Owner-controlled minting
- Owner-controlled pausing and unpausing
- Token burning with `burn()`
- Delegated burning with `burnFrom()`
- ERC-20 allowances
- Ownership transfer
- Access-control protection
- Foundry unit tests
- Ethereum Sepolia deployment
- Etherscan contract verification

## Technologies

- Solidity — smart contract programming language
- Foundry — development, testing, deployment, and interaction framework
- OpenZeppelin Contracts — reusable, battle-tested Solidity contract implementations
- Git — version control
- Ethereum Sepolia — test network

## Installation and Usage

### Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git
- A Sepolia RPC endpoint for testnet deployment
- A funded Sepolia testnet wallet for deployment

### Clone the repository

Clone the repository together with its Git submodules:
```bash
git clone --recurse-submodules https://github.com/rkcodecraft/community-token.git
cd community-token
```

If the repository was cloned without submodules, initialize them with:
```bash
git submodule update --init --recursive
```

The submodules provide:
- `lib/forge-std`
- `lib/openzeppelin-contracts`

### Build the project

```bash
forge build
```

### Run the tests

```bash
forge test
```

To include gas usage:
```bash
forge test --gas-report
```

The current test suite contains 18 tests.

### Run a local Anvil deployment

Start a local Anvil node in one terminal:
```bash
anvil
```

In a second terminal, deploy using one of Anvil's test private keys:
```bash
forge script script/DeployCommunityToken.s.sol:DeployCommunityToken \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast \
  --private-key <ANVIL_PRIVATE_KEY>
```

Use only Anvil-generated private keys for local development.

### Deploy to Sepolia

Create a local `.env` file based on the example file:
```bash
cp .env.example .env
```

Set your RPC URL, private key, and Etherscan API key in `.env`:
```dotenv
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_deployer_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

Never commit `.env` or any file containing private keys or API keys.

Export the variables in your terminal:
```bash
source .env
```

Then deploy:
```bash
forge script script/DeployCommunityToken.s.sol:DeployCommunityToken \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --broadcast \
  --private-key "$PRIVATE_KEY"
```

To verify the deployed contract on Etherscan, use the deployed contract address and constructor arguments required by the deployment script:
```bash
forge verify-contract <DEPLOYED_CONTRACT_ADDRESS> \
  src/CommunityToken.sol:CommunityToken \
  --chain sepolia \
  --etherscan-api-key "$ETHERSCAN_API_KEY"
```

The exact verification command may depend on the constructor arguments and the compiler settings in `foundry.toml`.

## Project Structure

```text
community-token/
├── src/
│   └── CommunityToken.sol
├── test/
│   └── CommunityToken.t.sol
├── script/
│   └── DeployCommunityToken.s.sol
├── lib/
│   ├── forge-std/
│   └── openzeppelin-contracts/
├── foundry.toml
├── foundry.lock
└── README.md
```

### Directory Overview

- `src/` — production smart contracts
- `src/CommunityToken.sol` — main CommunityToken contract
- `test/` — Foundry tests
- `test/CommunityToken.t.sol` — CommunityToken test suite
- `script/` — deployment scripts
- `lib/` — external Solidity dependencies
- `foundry.toml` — Foundry project configuration
- `foundry.lock` — dependency lock file

## Contract Architecture

CommunityToken builds on OpenZeppelin's standard contract implementations.

### ERC20

Provides standard ERC-20 functionality, including:

- Token balances
- Transfers
- Allowances
- Total supply
- Token metadata

### ERC20Burnable

Adds token-burning functionality:

- `burn()` — allows an account to burn its own tokens
- `burnFrom()` — allows an approved account to burn tokens on behalf of another account

### Ownable

Provides ownership and access control.
The contract uses `onlyOwner` to restrict administrative functions.
The owner controls:
- Minting
- Pausing
- Unpausing
- Ownership transfer

### ERC20Pausable

Provides the ability to pause token operations.
When the token is paused, transfers, minting, and burning are blocked.
The owner can unpause the token to restore normal operation.

## CommunityToken Contract

The project-specific contract defines:

- Token name: `Community Token`
- Token symbol: `CMT`
- Initial supply: `1,000,000 CMT`
- Owner-controlled `mint()`
- Owner-controlled `pause()`
- Owner-controlled `unpause()`

The contract uses OpenZeppelin implementations rather than implementing the ERC-20 standard from scratch.

## Testing

Run the complete test suite with:

```bash
forge test
```

The current test suite contains 18 passing tests covering:

- Initial token supply
- Token metadata
- Transfers
- Minting
- Owner access control
- Pausing
- Unpausing
- Transfers while paused
- Minting while paused
- Burning
- Burning more than the available balance
- burnFrom()
- ERC-20 allowances
- Expected transaction reverts

Current result:

```text
18 tests passed
0 failed
0 skipped
```

## Deployment

The contract was deployed to the Ethereum Sepolia test network.

### Sepolia Contract

```text
0xd1D2d8fb32a18eB410C62d8E13f6a1b13d948890
```

The deployed contract was verified on Etherscan.

> Private keys, API keys, and other secrets are stored locally and are not committed to the repository.

## Interacting With the Contract

The project uses Foundry's `cast` tool to interact with the deployed contract.

Examples include:

```bash
cast call
```

for read-only contract calls, and:

```bash
cast send
```

for transactions that modify blockchain state.

The project also explored:

- Function selectors
- ABI calldata encoding
- Transaction signing
- `msg.sender`
- `tx.origin`
- Event logs
- Contract storage slots
- Mapping storage
- ERC-20 allowances

## Key Solidity Concepts Learned

This project was used to learn:

- Solidity syntax and types
- Contract inheritance
- ERC-20 tokens
- `msg.sender`
- Constructors
- Ownership and access control
- Function visibility
- `public`, `private`, `internal`, and `external`
- Token balances
- Token allowances
- Events
- Function selectors
- ABI encoding
- Contract storage
- Mapping storage
- Foundry cheatcodes
- Solidity testing
- Blockchain transactions
- Gas and transaction execution
- Git-based development workflow

## Security Note

This project uses OpenZeppelin Contracts for standard ERC-20, ownership, burning, and pausing functionality.

However, this project has **not been professionally audited** and should not be considered production-ready or safe for handling real funds.

It is primarily a learning and portfolio project.

## Project Status

The initial CommunityToken implementation is complete.

### Completed

- Solidity contract implemented
- OpenZeppelin dependencies installed
- Foundry unit tests written
- Local Anvil testing
- Sepolia deployment
- Etherscan verification
- Token minting
- Token transfers
- ERC-20 approvals
- `transferFrom()`
- Token burning tests
- Pause/unpause testing
- Ownership transfer
- Contract interaction using `cast`
- Contract storage inspection
- Function selector and calldata exploration

## Future Improvements

Possible future improvements include:

- Add more comprehensive edge-case tests
- Add deployment configuration for multiple networks
- Improve automated deployment workflows
- Add a simple frontend for interacting with the token
- Add wallet connection using a Web3 library
- Add token activity/event monitoring
- Explore upgradeable-contract patterns
- Deploy additional portfolio projects using the concepts learned here