const PublicSet = artifacts.require('PublicSet')
//const AddressVotes = artifacts.require('AddressVotes')
const PublicStakeBank = artifacts.require('PublicStakeBank')
const Fts = artifacts.require('Fts')

const TokenRegistry = artifacts.require('TokenRegistry')
const BurnableERC20 = artifacts.require('BurnableERC20')

contract('PublicSet Unit Tests', accounts => {
  let set, fts
  const validator = accounts[0]
  const test_system = accounts[9]
  const tokenId = 'Test'

  beforeEach(async () => {
    // Create sample Hytch co2kn
    hytchToken = await BurnableERC20.new(10000, { from: validator })

    // Create co2kn whitelist and add hytch token
    co2knlist = await TokenRegistry.new({ from: validator })
    await co2knlist.setToken(tokenId, hytchToken.address, { from: validator })

    //av = await AddressVotes.new()
    fts = await Fts.new()
    await PublicSet.link('Fts', fts.address)
    set = await PublicSet.new(co2knlist.address, 1, 1, test_system)
  })

  it('Should deposit validator', async () => {
    // Mint tokens and enable staking
    await hytchToken.mint(accounts[1], 1000, { from: validator })
    await hytchToken.approve(await set.getStakeBankAddr(), 1000, {
      from: accounts[1]
    })

    // Join public set and stake 100 tokens
    await set.deposit(100, tokenId, { from: accounts[1] })

    // Check that it joined the set
    let x = await set.isInValidatorSet(accounts[1])
    assert.equal(x, true)
  })

  it('Should deposit and withdraw validator', async () => {
    // Mint tokens and enable staking
    await hytchToken.mint(accounts[1], 1000, { from: validator })
    await hytchToken.approve(await set.getStakeBankAddr(), 1000, {
      from: accounts[1]
    })

    // Join public set and stake 100 tokens
    await set.deposit(100, tokenId, { from: accounts[1] })

    // Check that it joined the set
    let x = await set.isInValidatorSet(accounts[1])
    assert.equal(x, true)

    await set.withdraw(0, { from: accounts[1] })

    // Should no longer be in set
    let y = await set.isInValidatorSet(accounts[1])
    assert.equal(y, false)
  })

  it('Finalize should choose a subset of validators', async () => {
    // Mint tokens and join public set
    for (let i = 1; i < 8; i++) {
      await hytchToken.mint(accounts[i], 100, { from: validator })
      await hytchToken.approve(await set.getStakeBankAddr(), 100, {
        from: accounts[i]
      })
      await set.deposit(100, tokenId, { from: accounts[i] })
    }

    let x = await set.finalizeChange({ from: test_system })

    let res = x.logs[x.logs.length - 1].args.current_set
    // Result from the seed 0x123
    let ans = [
      '0x12573c5a3601d1802b0a8a370583896a104c69c9',
      '0x74dffa4d2aa00f05b5cf757fbda4eaee5cced24a',
      '0xa704385c206afeb1956e1b58ff3c2f5bdfbc20b3',
      '0x74dffa4d2aa00f05b5cf757fbda4eaee5cced24a',
      '0x7dddd3c8bbbcbcd658d3175fa0e9d21f0a01d353',
      '0x12573c5a3601d1802b0a8a370583896a104c69c9',
      '0x12573c5a3601d1802b0a8a370583896a104c69c9',
      '0xa704385c206afeb1956e1b58ff3c2f5bdfbc20b3',
      '0xa61dea7e0bc66f88fa2c6f6bf0ff17008b8050ad',
      '0xa61dea7e0bc66f88fa2c6f6bf0ff17008b8050ad',
      '0xb6bb125bb669806db1916ee04c6c5b65ca417398',
      '0x45f358d4f49b45e445426ce0422e38c524d7d6f0',
      '0x74dffa4d2aa00f05b5cf757fbda4eaee5cced24a',
      '0x7dddd3c8bbbcbcd658d3175fa0e9d21f0a01d353',
      '0x45f358d4f49b45e445426ce0422e38c524d7d6f0',
      '0xa61dea7e0bc66f88fa2c6f6bf0ff17008b8050ad',
      '0x74dffa4d2aa00f05b5cf757fbda4eaee5cced24a',
      '0xb6bb125bb669806db1916ee04c6c5b65ca417398',
      '0x12573c5a3601d1802b0a8a370583896a104c69c9',
      '0x12573c5a3601d1802b0a8a370583896a104c69c9'
    ]
    assert.deepEqual(res, ans)
  })
})
