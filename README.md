# SIMPLE_CONTRACT_BOT
 Can be used to buy against a DEX of an EVM based blockchain that matches Pancakeswap V2 interfaces, includes tax limit and honeypot checker

## Libraries:

#### Truffle v5.5.21 (core: 5.5.21)
#### ganache v7.3.2 (@ganache/cli: 0.4.2, @ganache/core: 0.4.2)

## Commands to run the test against BSC fork:

```bash
ganache-cli --fork=https://bsc-dataseed1.binance.org/ --wallet.totalAccounts 20 --unlock 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3
```

```bash
truffle compile
truffle test --network developmentT
```
