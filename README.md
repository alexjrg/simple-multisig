
# Simple MultiSig Wallet

Simple MultiSig Wallet was made as a project for the [Cadena](https://cadena.dev/) course "Ethereum 101".

### !DO NOT USE IT!
There's a lot of debug features that should never be deployed in Mainnets!

## Installation

Use the package manager [npm](https://www.npmjs.com/) to install the environement.

```bash
npm install
```
Make sure to create a ```.env``` file with your Alchemy/Infura api url and the private key of the contract creator's wallet.
```
ALCHEMY_RINKEBY_URL=<URL>
RINKEBY_PRIVATE_KEY=<PRIVATE KEY>
```

## Usage

This project use [hardhat](https://hardhat.org/), deploy your smartcontract with the following command :
```bash
npx hardhat --network rinkeby
```

## Contributing
This project won't be continued.

## License
[GPL-3.0](https://choosealicense.com/licenses/gpl-3.0/)
