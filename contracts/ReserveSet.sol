pragma solidity ^0.4.23;

import "./MajoritySet.sol";

import "./StakingSet.sol";

contract ReserveSet is MajoritySet {
  StakingSet stakingSet;

  constructor() public {
  }
}
