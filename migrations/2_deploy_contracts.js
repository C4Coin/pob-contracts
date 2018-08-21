const ConsortiumSet = artifacts.require('ConsortiumSet')
const AddressVotes = artifacts.require('AddressVotes')

module.exports = deployer => {
  deployer.deploy(AddressVotes).then(() => {
    deployer.link(AddressVotes, ConsortiumSet)
    deployer.deploy(ConsortiumSet)
  })
}
