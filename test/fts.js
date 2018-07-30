const FtsLib = artifacts.require('Fts')

contract('Fts library', accounts => {
  let ftsLib

  it('Should return the second staker from the list', async () => {
    ftsLib = await FtsLib.new()

    let staker = await ftsLib.fts.call(
      '00',
      accounts.slice(0, 4),
      [10, 110, 610, 650],
      651
    )

    assert.equal(staker, accounts[1])
  })
})
