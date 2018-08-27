const ConsortiumSet = artifacts.require('ConsortiumSet')
const AddressVotes = artifacts.require('AddressVotes')
const Fts = artifacts.require('./libraries/Fts.sol')
const FtsAdapter = artifacts.require('./FtsAdapter.sol')

module.exports = deployer => {
  deployer.deploy(AddressVotes).then(() => {
    deployer.link(AddressVotes, ConsortiumSet)
    deployer.deploy(ConsortiumSet)
    
    deployer.deploy(Fts)
    deployer.link(Fts, FtsAdapter)
    deployer.deploy(FtsAdapter)
  })
}