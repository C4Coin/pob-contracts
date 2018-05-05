# validator-contracts

Smart contracts implementing validators

* `develop` — [![CircleCI](https://circleci.com/gh/C4Coin/validator-contracts/tree/develop.svg?style=svg)](https://circleci.com/gh/C4Coin/validator-contracts/tree/develop) [codecov badge]
* `master` — [![CircleCI](https://circleci.com/gh/C4Coin/validator-contracts/tree/master.svg?style=svg)](https://circleci.com/gh/C4Coin/validator-contracts/tree/master) [codecov badge]

## Overview

_to be filled_

### Requirements

_to be filled_

## Development

The smart contracts are being implemented in Solidity `0.4.23`.

### Development Prerequisites

* [NodeJS](htps://nodejs.org), version 10+ or better (I use [`nvm`](https://github.com/creationix/nvm) to manage Node versions — `brew install nvm`.)
* [truffle](http://truffleframework.com/), which is a comprehensive framework for Ethereum development. `npm install -g truffle` — this should install Truffle v4.1.7 or better.  Check that with `truffle version`.
* [Access to the C4Coin Jira](https://c4coin.atlassian.net)

### Initialisation

    npm install

### Testing

#### Standalone

    npm test

or with code coverage

    npm run test:cov

#### From within Truffle

Run the `truffle` development environment

    truffle develop

then from the prompt you can run

    compile
    migrate
    test

as well as other Truffle commands. See [truffleframework.com](http://truffleframework.com) for more.

### Linting

We provide the following linting options

* `npm run lint:sol` — to lint the Solidity files, (although this is currently not working)
* `npm run lint:js` — to lint the Javascript.

## Contributing

Please see the [contributing notes](CONTRIBUTING.md).
