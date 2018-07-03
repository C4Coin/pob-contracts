pragma solidity ^0.4.23;

import "./interfaces/ValidatorSet.sol";
import "./interfaces/ValidatorSet.sol";
import "./interfaces/StakeBankInterface.sol";
import "./DelayedStakeBank.sol";
// Burn library


contract PublicStakingSet is ValidatorSet {
    // Wrap and track latest stakers
    ERC20 token;
    DelayedStakeBank delayedStakeBank;

    constructor() public {

    }
}
