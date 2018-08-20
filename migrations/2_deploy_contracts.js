const Fts = artifacts.require('./libraries/Fts.sol')
const FtsAdapter = artifacts.require('./FtsAdapter.sol')

module.exports = function(deployer) {
  deployer.deploy(Fts)
  deployer.link(Fts, FtsAdapter)
  deployer.deploy(FtsAdapter)
}
