var Fts = artifacts.require('./libraries/Fts.sol')
var FtsAdapter = artifacts.require('./libraries/FtsAdapter.sol')

module.exports = function(deployer) {
  deployer.deploy(Fts).then(() => {
    deployer.deploy(FtsAdapter)
  })
  deployer.link(Fts, FtsAdapter)
}
