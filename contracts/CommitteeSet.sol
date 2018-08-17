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
import './ConsortiumSetSingleton.sol';
import './PublicSetSingleton.sol';


// @title Contract to create committee from consortium and public validators
// @notice Committees change every dynasty
contract CommitteeSet is SystemValidatorSet {
    SystemValidatorSet private consortiumSet = ConsortiumSetSingleton.instance();
    SystemValidatorSet private publicSet = PublicSetSingleton.instance();

    address[] private validatorsList;

    uint256 internal constant maxValidators = 80;
    uint256 consortiumToPublicRatio = 3;

    /// Get current validator set (last enacted or initial if no changes ever made)
    function getValidators() public constant returns (address[]) {
        return validatorsList;
    }

    /// Called when an initiated change reaches finality and is activated.
    /// Only valid when msg.sender == SYSTEM (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    function finalizeChange() public onlySystemAndNotFinalized {
        if (isChangingDynasty()) {
            consortiumSet.finalizeChange();
            publicSet.finalizeChange();

            address[] memory consortiumList = consortiumSet.getValidators();
            address[] memory publicList = publicSet.getValidators();

            uint256 indexConsortium = 0;
            uint256 indexPublic = 0;
            uint256 i = 0;
            // If public nodes > 25% then add more consortium validators
            if ( publicList.length * consortiumToPublicRatio >= consortiumList.length) {
                // Calculate how many more consortium members we need
                uint256 deltaConsortium = publicList.length * consortiumToPublicRatio - consortiumList.length;
                for( i=0; i < deltaConsortium; i++) {
                    /* consortiumList.push(consortiumList[i]);  */
                }
            }

            // Zip validators to form committee
            address[] memory committeeList = new address[](maxValidators);
            for (i = 0; i < maxValidators; i++) {
                if (i % (consortiumToPublicRatio + 1) == 0) {
                    // Move foreward in public val. if we can and update committee
                    if (indexPublic < publicList.length) {
                        committeeList[i] = publicList[indexPublic];
                        indexPublic++;
                    }
                    continue;
                } else {
                    indexConsortium++;
                }
                committeeList[i] = consortiumList[indexConsortium];
            }

            validatorsList = committeeList;
        }

        finalized = true;
        emit ChangeFinalized(validatorsList);
    }

    // Reporting functions: operate on current validator set.
    // malicious behavior requires proof, which will vary by engine.
    function reportBenign(address validator, uint256 blockNumber) public {
        if (consortiumSet.isInValidatorSet(validator)) {
            consortiumSet.reportBenign(validator, blockNumber);
        } else if (publicSet.isInValidatorSet(validator)) {
            publicSet.reportBenign(validator, blockNumber);
        } else {
            emit SystemValidatorError("reportBenign given invalid address");
        }
    }

    function reportMalicious(address validator, uint256 blockNumber, bytes proof) public {
        if (consortiumSet.isInValidatorSet(validator)) {
            consortiumSet.reportMalicious(validator, blockNumber, proof);
        } else if (publicSet.isInValidatorSet(validator)) {
            publicSet.reportMalicious(validator, blockNumber, proof);
        } else {
            emit SystemValidatorError("reportMalicious given invalid address");
        }
    }
}
