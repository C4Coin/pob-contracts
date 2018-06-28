pragma solidity ^0.4.23;

import './Lockable.sol';


contract LockableSeed is Lockable {
  uint private seed;

  function getSeed() public constant returns (uint) {
    return seed;
  }

  function setSeed(uint _seed) onlyOwner, onlyWhenUnlocked {
    seed = _seed;
  }
}
