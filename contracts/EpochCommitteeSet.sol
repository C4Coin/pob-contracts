pragma solidity ^0.4.23;

import "./interfaces/ValidatorSet.sol";
import "./interfaces/LockableSeed.sol";
import "./MajoritySet.sol";
import "./PublicStakingSet.sol";


contract EpochCommitteeSet is ValidatorSet, LockableSeed {
    MajoritySet consortiumSet;
    PublicStakingSet publicSet;

    function getValidators() {
        // var stakers, balances = ;
    }
}
