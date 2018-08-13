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


/**
 * @title Interface for a validator set that can interface with parity engines
 */
contract IValidatorSet {
    /// Constants used by all validator sets
    // System address, used by the block sealer.
    address internal constant SYSTEM_ADDRESS = 0x00fffffffffffffffffffffffffffffffffffffffe;
    // Time after which the validators will report a validator as malicious.
    uint internal constant MAX_INACTIVITY = 6 hours;
    // Ignore misbehaviour older than this number of blocks.
    uint internal constant RECENT_BLOCKS = 20;

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
    function getValidators() public constant returns (address[]);

    /// Called when an initiated change reaches finality and is activated.
    /// Only valid when msg.sender == SYSTEM (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    function finalizeChange() public;

    // Reporting functions: operate on current validator set.
    // malicious behavior requires proof, which will vary by engine.

    function reportBenign(address validator, uint256 blockNumber) public;
    function reportMalicious(address validator, uint256 blockNumber, bytes proof) public;
}
