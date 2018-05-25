pragma solidity ^0.4.23;

contract GeltFixedValidatorSet {
  // Current list of addresses entitled to participate in the consensus.
  address[] public validatorsList = [
    0x0082a978b3f5962a5b0957d9ee9eef472ee55b42f1,
    0x007d577a597b2742b498cb5cf0c26cdcd726d39e6e
  ];

  constructor() public {
  }
  /// Issue this log event to signal a desired change in validator set.
  /// This will not lead to a change in active validator set until
  /// finalizeChange is called.
  ///
  /// Only the last log event of any block can take effect.
  /// If a signal is issued while another is being finalized it may never
  /// take effect.
  ///
  /// _parentHash here should be the parent block hash, or the
  /// signal will not be recognized.
  event InitiateChange(bytes32 indexed _parentHash, address[] _newSet);

  /// Get current validator set (last enacted or initial if no changes ever made)
  function getValidators() public constant returns (address[]) {
      return validatorsList;
  }

  /// Called when an initiated change reaches finality and is activated.
  /// Only valid when msg.sender == SYSTEM (EIP96, 2**160 - 2)
  ///
  /// Also called when the contract is first enabled for consensus. In this case,
  /// the "change" finalized is the activation of the initial set.
  function finalizeChange() public {

  }

  // Reporting functions: operate on current validator set.
  // malicious behavior requires proof, which will vary by engine.

  function reportBenign(address validator, uint256 blockNumber) public {

  }

  function reportMalicious(address validator, uint256 blockNumber, bytes proof) public {

  }
}
