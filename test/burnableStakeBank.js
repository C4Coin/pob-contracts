const BurnableStakeBank = artifacts.require('BurnableStakeBank')
//const StakeBank = artifacts.require('StakeBank');
const ConsensusToken = artifacts.require('ConsensusToken')

contract('Burn dem tokes', ([owner, staker]) => {
  let token, burnBank

  beforeEach(async () => {
    const tokenCap = 1000
    token = await ConsensusToken.new(tokenCap, { from: owner })
    burnBank = await BurnableStakeBank.new(token.address)

    // Mint tokens
    await token.mint(owner, 1000, { from: owner })
    // Staker gets 100 tokens
    //await token.transfer(staker, 100, { from: owner })
  })

  it('Stake and burn tokens', async () => {
    await token.approve(burnBank.address, 100, { from: owner })
    await burnBank.stakeFor(owner, 100, '0x0', { from: owner })

    let staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 100)
  })
})
