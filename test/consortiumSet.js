const ConsortiumSet = artifacts.require('ConsortiumSet')
const AddressVotes = artifacts.require('AddressVotes')

contract('Consortium Unit Tests', accounts => {
  let set
  const validator = accounts[0]
  const test_system = accounts[9]

  beforeEach(async () => {
    av = await AddressVotes.new()
    set = await ConsortiumSet.new([validator], test_system)
  })

  it('Ctor should populate with initial validators', async () => {
    const val_list = await set.getValidators()
    console.log('val list: ' + val_list)
    assert.deepEqual(val_list, [validator]) //['0xf5777f8133aae2734396ab1d43ca54ad11bfb737'])
  })

  it('isInValidatorSet handles edge cases', async () => {
    const val_list = await set.getValidators()
    const res = await set.isInValidatorSet(val_list[0])
    assert.equal(res, true)
    const res2 = await set.isInValidatorSet('0x0')
    assert.equal(res2, false)
  })

  it('Should add a validator only when supported', async () => {
    // First finalize to allow addSupport to initiate change
    await set.finalizeChange({ from: test_system })

    const new_val = accounts[1]

    // First try to add validator without support.
    // This should fail
    try {
      await set.addValidator(new_val, { from: validator })
      assert.fail("Expected a revert but it didn't happen...")
    } catch (e) {
      const revertFound = e.message.search('revert') >= 0
      assert(revertFound, `Expected "revert", got ${e} instead`)
    }

    // Then add support, which will call addValidator
    await set.addSupport(new_val, { from: validator })

    await set.finalizeChange({ from: test_system })

    assert.deepEqual(await set.getValidators(), [validator, accounts[1]])
  })

  it('Add and remove a validator', async () => {
    const new_val = accounts[1]

    // Add new validator
    await set.finalizeChange({ from: test_system })
    await set.addSupport(new_val, { from: validator })
    await set.finalizeChange({ from: test_system })

    // Remove new validator by removing support
    await set.reportMalicious(new_val, 0, '0x0', { from: validator })
    await set.finalizeChange({ from: test_system })

    // Should only have the original validator
    assert.deepEqual(await set.getValidators(), [validator])
  })

  it('Validator list should not update until finalize', async () => {
    const new_val = accounts[1]
    const newer_val = accounts[2]

    /*
     * Add first new validator
     */
    await set.finalizeChange({ from: test_system })
    await set.addSupport(new_val, { from: validator })

    // Shouldn't be there since its not finalized
    assert.deepEqual(await set.getValidators(), [validator])

    // Now finalize
    await set.finalizeChange({ from: test_system })

    // And it should be there
    assert.deepEqual(await set.getValidators(), [validator, new_val])

    /*
     * Add next new validator
     */
    await set.addSupport(newer_val, { from: validator })
    await set.addSupport(newer_val, { from: new_val })

    // Shouldn't be there yet
    assert.deepEqual(await set.getValidators(), [validator, new_val])

    // Now finalize
    await set.finalizeChange({ from: test_system })

    // And it should be there
    assert.deepEqual(await set.getValidators(), [validator, new_val, newer_val])
  })
})
