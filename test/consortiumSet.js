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

  it('Should add a validator', async () => {
    const new_val = '0xf'
    await set.addValidator(new_val)

    assert.deepEqual(await set.getValidators(), [
      '0xf5777f8133aae2734396ab1d43ca54ad11bfb737',
      '0xf'
    ])
  })

  it('Should add a validator only when supported', async () => {
    //const new_val = '0xf'
    const new_val = accounts[1]
    await set.addSupport(new_val, {
      from: '0xf5777f8133aae2734396ab1d43ca54ad11bfb737'
    })
    await set.addValidator(new_val, {
      from: '0xf5777f8133aae2734396ab1d43ca54ad11bfb737'
    })

    assert.deepEqual(await set.getValidators(), [
      '0xf5777f8133aae2734396ab1d43ca54ad11bfb737',
      accounts[1]
    ])
  })
})
