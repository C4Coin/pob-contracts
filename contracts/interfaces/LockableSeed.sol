pragma solidity ^0.4.23;

import './Lockable.sol';


contract LockableSeed is Lockable {
    uint public seed;

    function setSeed(uint _seed) onlyOwner, onlyWhenUnlocked {
        seed = _seed;
    }
}
