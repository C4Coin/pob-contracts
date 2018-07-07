/*
Smart-contracts for the C4Coin PoB consensus protocol.
Copyright (C) 2018  tigran@c4coin.org

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
pragma solidity ^0.4.24;


import '../interfaces/IValidatorSet.sol';


/**
 * @title Contract used as a mock for a consoritum validator set
 */
contract GeltFixedValidatorSet is IValidatorSet {
    // Current list of addresses entitled to participate in the consensus.
    address[] public validatorsList = [
        0x0082a978b3f5962a5b0957d9ee9eef472ee55b42f1,
        0x007d577a597b2742b498cb5cf0c26cdcd726d39e6e
    ];

    event InitiateChange(bytes32 indexed _parentHash, address[] _newSet);

    // Get current validator set
    function getValidators() public constant returns (address[]) {
        return validatorsList;
    }

    /// Called when an initiated change reaches finality and is activated.
    function finalizeChange() public;

    // Benign misbehavior from unavailability or other network issues
    // Not implemented, but required for a non-safe validator contract interface.
    function reportBenign(address validator, uint256 blockNumber) public;

    // Malicious behavior requires proof, which will vary by engine.
    // Not implemented, but required for a non-safe validator contract interface.
    function reportMalicious(address validator, uint256 blockNumber, bytes proof) public;
}
