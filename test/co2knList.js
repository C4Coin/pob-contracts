const Co2knList = artifacts.require('Co2knList')
const BurnableERC20 = artifacts.require('BurnableERC20')

contract('Co2knList contract', ([owner, pleb]) => {
  let hytchToken

  beforeEach(async () => {
    // Create sample Hytch co2kn
    hytchToken = await BurnableERC20.new(1000, { from: owner })

    // Create co2kn whitelist and add hytch token
    co2knlist = await Co2knList.new({ from: owner })
    await co2knlist.setToken('Hytch', hytchToken.address, { from: owner })
  })

  // Test contains
  it('Method contain should match token hash', async () => {
    assert.equal(await co2knlist.contains('Hytch'), true)
  })
  it('Method contain should not match this hash', async () => {
    assert.equal(await co2knlist.contains('Nada'), false)
  })

  // Test getAddress
  it('Method getAddress should get token address', async () => {
    assert.equal(await co2knlist.getAddress('Hytch'), hytchToken.address)
  })
  it('Method getAddress should revert on hash not in list', async () => {
    try {
      await co2knlist.getAddress('Nada')
      assert.fail("Expected a revert but it didn't happen...")
    } catch (e) {
      const revertFound = e.message.search('revert') >= 0
      assert(revertFound, `Expected "revert", got ${e} instead`)
    }
  })

  // Test setToken
  it('Should not be able to setToken if not owner', async () => {
    try {
      await co2knlist.setToken('Hytch', hytchToken.address, { from: pleb })
      assert.fail("Expected a revert but it didn't happen...")
    } catch (e) {
      const revertFound = e.message.search('revert') >= 0
      assert(revertFound, `Expected "revert", got ${e} instead`)
    }
  })
})
