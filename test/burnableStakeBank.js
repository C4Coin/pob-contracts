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

    // Stake owner
    await token.approve(burnBank.address, 100, { from: owner })
    await burnBank.stake(100, '0x0', { from: owner })

    // Tokens should be staked
    let staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 100)
  })

  it('Owner stake and burn, results in none staked', async () => {
    // Burn
    await burnBank.burnFor(owner, 100, '0x0', { from: owner })

    // Should no longer be staked
    staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 0)

    // Should have burned 100
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 100)
  })

  it('TotalBurnedForAt returns owner burn amount', async () => {
    // Burn
    await burnBank.burnFor(owner, 100, '0x0', { from: owner })

    // Should have burned 100
    burned = (await burnBank.totalBurnedForAt(
      owner,
      web3.eth.blockNumber
    )).toNumber()
    assert.equal(burned, 100)
  })

  it('TotalBurnedAt returns sum burn of two users', async () => {
    // Second user stakes
    await token.transfer(staker, 50, { from: owner })
    await token.approve(burnBank.address, 50, { from: staker })
    await burnBank.stake(50, '0x0', { from: staker })

    // Owner burns 100
    await burnBank.burnFor(owner, 100, '0x0', { from: owner })
    // Staker burns 50
    await burnBank.burnFor(staker, 50, '0x0', { from: staker })

    // Should have burned 100+50 total
    burned = (await burnBank.totalBurnedAt(web3.eth.blockNumber)).toNumber()
    assert.equal(burned, 150)
  })
})
