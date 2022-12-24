# SIMPLE_CONTRACT_BOT
 Can be used to buy against a DEX of an EVM based blockchain, includes tax limit and honeypot checker

### Commands and libraries to run the test against BSC fork:

Truffle v5.5.21 (core: 5.5.21)
ganache v7.3.2 (@ganache/cli: 0.4.2, @ganache/core: 0.4.2)

```ganache-cli --fork=https://bsc-dataseed1.binance.org/ --wallet.totalAccounts 20 --unlock 0x8894E0a0c962CB723c1976a4421c95949bE2D4E3```

```truffle compile```
```truffle test --network developmentT```
