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


import './interfaces/SystemValidatorSet.sol';
import './interfaces/LockableSeed.sol';
import './ConsortiumSet.sol';
import './ConsortiumSetSingleton.sol';
import './PublicSet.sol';
import './PublicSetSingleton.sol';


// @title Contract to create committee from consortium and public validators
// @notice Committees change every dynasty
contract CommitteeSet is SystemValidatorSet, LockableSeed {
    ConsortiumSet private consortiumSet = ConsortiumSetSingleton.instance();
    PublicSet private publicSet = PublicSetSingleton.instance();

    address[] private validatorsList;

    // STATE
    // Support can not be added once this number of validators is reached.
    uint internal constant MAX_VALIDATORS = 50;
    uint consortiumToPublicRatio = 3;

    constructor() public {
        validatorsList.push(address(0));
    }

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
