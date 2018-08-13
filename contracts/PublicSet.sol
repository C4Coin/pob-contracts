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


import './interfaces/IValidatorSet.sol';
import './PublicStakeBank.sol';
import './PublicStakeBankSingleton.sol';


// @title Contract for public validators that wraps the stake bank used by public stakers
contract PublicSet is IValidatorSet {
    PublicStakeBank private publicStakeBank = PublicStakeBankSingleton.instance();

    uint internal constant MAX_VALIDATORS = 10;

    address[] private validatorsList;

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
