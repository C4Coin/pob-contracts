const BurnableERC20 = artifacts.require('BurnableERC20')
const TokenRegistry = artifacts.require('TokenRegistry')
const BurnableStakeBank = artifacts.require('BurnableStakeBank')

contract('BurnableStakeBank contract', ([owner, staker1, staker2]) => {
  let token, burnBank, co2knlist
  const tokenCap = 1000
  const minimumStake = 50

  beforeEach(async () => {
    // Create co2kn instance
    token = await BurnableERC20.new(tokenCap, { from: owner })

    // Create co2kn whitelist and add token
    co2knlist = await TokenRegistry.new({ from: owner })
    await co2knlist.setToken('test', token.address, { from: owner })

    // Create BurnableStakeBank
    burnBank = await BurnableStakeBank.new(co2knlist.address, minimumStake, {
      from: owner
    })

    // Mint tokens
    await token.mint(owner, 1000, { from: owner })

    // Stake owner
    await token.approve(burnBank.address, 100, { from: owner })
    await burnBank.stake(100, 'test', { from: owner })

    // Tokens should be staked
    let staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 100)
  })

  it('Should not be able to stake lower than minimum stake', async () => {
    try {
      // Stake lower than minimum
      await token.approve(burnBank.address, 30, { from: owner })
      await burnBank.stake(30, 'test', { from: owner })

      assert.fail("Expected a revert but it didn't happen...")
    } catch (e) {
      const revertFound = e.message.search('revert') >= 0
      assert(revertFound, `Expected "revert", got ${e} instead`)
    }
  })

  it('Should not be able to unstake to lower than minimum stake', async () => {
    try {
      // Unstake to lower than minimum
      await burnBank.unstake(80, 'test', { from: owner })

      assert.fail("Expected a revert but it didn't happen...")
    } catch (e) {
      const revertFound = e.message.search('revert') >= 0
      assert(revertFound, `Expected "revert", got ${e} instead`)
    }
  })

  it('Owner stake and burn, results in none staked', async () => {
    // Burn
    await burnBank.burnFor(owner, 100, 'test', { from: owner })

    // Should no longer be staked
    staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 0)

    // Should have burned 100
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 100)
  })

  it('TotalBurnedForAt returns owner burn amount', async () => {
    // Burn
    await burnBank.burnFor(owner, 100, 'test', { from: owner })

    // Should have burned 100
    burned = (await burnBank.totalBurnedForAt(
      owner,
      web3.eth.blockNumber
    )).toNumber()
    assert.equal(burned, 100)
  })

  it('TotalBurnedAt returns sum of two burns', async () => {
    // First user stakes minimum of 50
    await token.transfer(staker1, 50, { from: owner })
    await token.approve(burnBank.address, 50, { from: staker1 })
    await burnBank.stake(50, 'test', { from: staker1 })

    // Verify the total stake (100+50)
    staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 150)

    // Verify the total staked for staker 1 (50)
    let stakedFor = (await burnBank.totalStakedFor(staker1)).toNumber()
    assert.equal(stakedFor, 50)

    // Verify the total burned is 0
    let burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 0)

    // Second user stakes 150
    await token.transfer(staker2, 150, { from: owner })
    await token.approve(burnBank.address, 150, { from: staker2 })
    await burnBank.stake(150, 'test', { from: staker2 })

    // Verify the total stake (100+50+150)
    staked = (await burnBank.totalStaked()).toNumber()
    assert.equal(staked, 300)

    // Verify the total staked for staker 2 (50)
    stakedFor = (await burnBank.totalStakedFor(staker2)).toNumber()
    assert.equal(stakedFor, 150)

    // Verify the total burned is still 0
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 0)

    // Owner burns first user's stake
    await burnBank.burnFor(staker1, 50, 'test', { from: owner })

    // Verify the total burned is 50
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 50)

    // Owner burns second user's stake
    await burnBank.burnFor(staker2, 150, 'test', { from: owner })

    // Verify the total burned is 200
    burned = (await burnBank.totalBurned()).toNumber()
    assert.equal(burned, 200)

    burned = (await burnBank.totalBurnedAt(web3.eth.blockNumber)).toNumber()
    assert.equal(burned, 200)
  })
})
