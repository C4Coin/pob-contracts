const BurnableStakeBank = artifacts.require('BurnableStakeBank')
const ConsensusToken = artifacts.require('ConsensusToken')

contract('BurnableStakeBank contract', ([owner, staker]) => {
  let token, burnBank
  const tokenCap = 1000

  beforeEach(async () => {
    token = await ConsensusToken.new(tokenCap, { from: owner })
    burnBank = await BurnableStakeBank.new(token.address)

    // Mint tokens
    await token.mint(owner, 1000, { from: owner })
  })

  it('Owner stake and burn, results in none staked', async () => {
    // Stake
    await token.approve(burnBank.address, 100, { from: owner })
    await burnBank.stake(100, '0x0', { from: owner })

    // Tokens should be staked
    let staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 100)

    // Burn
    await burnBank.burnFor(owner, 100, '0x0', { from: owner })

    // Should no longer be staked
    staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 0)
    // Should have burned 100
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 100)
  })
})
