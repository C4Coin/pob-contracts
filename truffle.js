const {
  name: packageName,
  version,
  description,
  keywords,
  license,
  author,
  contributors
} = require('./package.json')

module.exports = {
  packageName,
  version,
  description,
  keywords,
  license,
  authors: [author, ...contributors],
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*'
    }
    // ropsten: {
    //   network_id: 3,
    //   provider: engineRopsten,
    //   from: addresses[0],
    //   gas: 4700000,
    //   gasPrice: 222000000000
    // },
    // mainnet: {
    //   network_id: 1,
    //   provider: engineMainnet,
    //   from: addresses[0],
    //   gas: 5000000,
    //   gasPrice: 75000000000
    // }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
}
