pragma solidity ^0.4.23;

import "./interfaces/ValidatorSet.sol";
import "./interfaces/LockableSeed.sol";
import "./MajoritySet.sol";
import "./PublicStakingSet.sol";


contract EpochSet is ValidatorSet, LockableSeed {
  PublicStakingSet publicSet;
  MajoritySet privelagedSet;

  // Return public and privelaged validators for this epoch
  function getValidators() {
  }
}
