const FtsLib = artifacts.require('Fts')

contract('Fts library', accounts => {
  let ftsLib

  it('Should return the second staker from the list', async () => {
    ftsLib = await FtsLib.new()

    // Hash of "00" as a uint256 is 1.8569430475105882587588266137607568536673111973893317399460219858819262702947e+76
    // That number % totalCoin (651) is 162
    // Index 162 equates to 2nd account

    let staker = await ftsLib.fts.call(
      '00',
      accounts.slice(0, 4),
      [10, 110, 610, 650],
      651
    )

    assert.equal(staker, accounts[1])
  })

  it('Should return the first staker from the list', async () => {
    ftsLib = await FtsLib.new()

    // Hash of "123" as a uint256 is 5.320535884217948059154257054001672881197643928609443669088116914333526164331e+76
    // That number % totalCoin (651) is 37
    // Index 37 equates to 1st account

    let staker = await ftsLib.fts.call(
      '123',
      accounts.slice(0, 4),
      [10, 110, 610, 650],
      651
    )

    assert.equal(staker, accounts[0])
  })
})
