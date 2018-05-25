pragma solidity ^0.4.23;

import "../interfaces/ValidatorSet.sol";

contract GeltFixedValidatorSet {
  // Current list of addresses entitled to participate in the consensus.
  address[] public validatorsList;

  constructor() public {
    validatorsList.push(0x0082a978b3f5962a5b0957d9ee9eef472ee55b42f1);
    validatorsList.push(0x007d577a597b2742b498cb5cf0c26cdcd726d39e6e);
  }

  // Called on every block to update node validator list.
  function getValidators() public constant returns (address[]) {
      return validatorsList;
  }
}
