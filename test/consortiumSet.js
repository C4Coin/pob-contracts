const ConsortiumSet = artifacts.require('ConsortiumSet')
const AddressVotes = artifacts.require('AddressVotes')

contract('Consortium Unit Tests', accounts => {
  let set
  beforeEach(async () => {
    av = await AddressVotes.new()
    set = await ConsortiumSet.new()
  })

  it('Ctor should populate with initial validators', async () => {
    const val_list = await set.getValidators()
    assert.deepEqual(val_list, ['0xf5777f8133aae2734396ab1d43ca54ad11bfb737'])
  })

  it('isInValidatorSet handles edge cases', async () => {
    const val_list = await set.getValidators()
    const res = await set.isInValidatorSet(val_list[0])
    assert.equal(res, true)
    const res2 = await set.isInValidatorSet('0x0')
    assert.equal(res2, false)
  })
})
