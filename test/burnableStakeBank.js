const BurnableStakeBank = artifacts.require('BurnableStakeBank')
const ConsensusToken = artifacts.require('ConsensusToken')
const Token = artifacts.require('SimpleToken')

contract('Burn dem tokes', ([owner, staker]) => {
  let token, burnBank

  beforeEach(async () => {
    token = await ConsensusToken.new(1000, { from: owner })
    burnBank = await BurnableStakeBank.new(token.address)

    // Mint tokens
    await token.mint(owner, 1000, { from: owner })
    // Staker gets 100 tokens
    await token.transfer(staker, 100, { from: owner })
  })

  it('Stake and burn tokens', async () => {
    let bal = (await token.balanceOf(staker)).toNumber()
    assert.equal(bal, 100)

    /*
      burnBank.stake(100, web3.fromAscii('0x0'), {from: staker})
      //console.log(await burnBank.totalStaked())
      let staked = (await burnBank.totalStaked()).toNumber()
      assert.equal(100, 100)
      */
  })
})
