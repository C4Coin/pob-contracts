const Fts = artifacts.require('./libraries/Fts.sol')
const FtsAdapter = artifacts.require('./FtsAdapter.sol')

module.exports = deployer => {
  deployer.deploy(Fts).then(() => {
    deployer.link(Fts, FtsAdapter)
    deployer.deploy(FtsAdapter)
  })

  // TODO:
  // Deploy PublicStakeBankSingleton & TokenRegistrySingleton
}
