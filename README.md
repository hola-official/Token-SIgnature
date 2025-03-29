## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

# TokenSig

A Solidity project containing two smart contracts: a signature-based token minting contract and a bitmap storage contract.

## Contracts

### TOKENSIGNER

A signature-based ERC20 token contract that allows minting tokens using cryptographic signatures.

#### Features
- Mint tokens using signatures from the owner
- ERC20 standard implementation
- Signature verification for secure minting
- Owner-based authorization

#### Usage
```solidity
// Mint tokens with a valid signature
function mintWithSignature(address recipient, uint256 amount, bytes memory signature)
```

### BitmapStorage

A gas-efficient contract that uses a single uint256 to store 32 byte values (0-255).

#### Features
- Store up to 32 byte values in a single uint256
- Efficient storage using bit manipulation
- Individual slot access and bulk retrieval
- Range validation for slots and values

#### Usage
```solidity
// Store a value in a specific slot
function storeValue(uint8 slot, uint256 value)

// Get value from a specific slot
function getValue(uint8 slot)

// Get all values
function getAllValues()
```

## Testing

The project includes comprehensive tests for both contracts:

### TOKENSIGNER Tests
- Initial state verification
- Valid signature minting
- Multiple mint operations
- Multi-user minting
- Invalid signature handling
- Wrong address/amount handling
- Empty signature handling

### BitmapStorage Tests
- Initial state verification
- Basic storage and retrieval
- Maximum value storage
- Zero value storage
- Multiple value storage
- Value overwriting
- All slots usage
- Edge cases
- Invalid input handling

## Development

### Prerequisites
- Solidity ^0.8.13
- Foundry
- OpenZeppelin Contracts

### Setup
1. Clone the repository
2. Install dependencies:
```bash
forge install
```

### Testing
Run the test suite:
```bash
forge test -vv
```

## License
UNLICENSED
