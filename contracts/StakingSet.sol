pragma solidity ^0.4.23;

import "./interfaces/ValidatorSet.sol";
import "./StakeBank.sol";

contract StakingSet is ValidatorSet {
  StakeBank stakeBank;

  constructor() public {
  }
}
