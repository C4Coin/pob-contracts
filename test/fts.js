const FtsAdapter = artifacts.require('FtsAdapter')

contract('Fts library', accounts => {
  let ftsAdapter

  beforeEach(async () => {
    ftsAdapter = await FtsAdapter.new()
  })

  it('Should return the second staker from the list', async () => {
    // Hash of "00" as a uint256 is 1.8569430475105882587588266137607568536673111973893317399460219858819262702947e+76
    // That number % totalCoin (650) is 197
    // Index 197 equates to 3rd account
    // Hash of that hash as uint256 is 7.7325989696766893111127756213298094134926739482120969801295632937101989508141e+76
    // That number % totalCoin (650) is 162
    // Index 162 equates to 3rd account
    // console.log(ftsLib);
    // console.log(ftsLib);
    let staker = await ftsAdapter.fts.call(
      '00',
      accounts.slice(0, 4), // Staker address list
      [0, 10, 110, 610, 650], // Accumulated index list with a 0 prepended
      650, // Total coins
      2 // Number of blocks
    )

    assert.deepEqual(staker, [accounts[2], accounts[2]])
  })
})
