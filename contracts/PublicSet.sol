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
import './interfaces/IPublicStakeBank.sol';
//import './PublicStakeBankSingleton.sol';
import './PublicStakeBank.sol';
import './libraries/Fts.sol';
import './TokenRegistry.sol';
import './interfaces/CustomOwnable.sol';


// @title Contract for public validators that wraps the stake bank used by public stakers
contract PublicSet is SystemValidatorSet, CustomOwnable {
    event Withdraw(address addr);
    event Deposit(address addr, uint256 index);

    IPublicStakeBank private publicStakeBank;

    uint internal constant maxValidators = 20;

    uint256 curDynasty = 0;

    struct Validator {
        uint256 startDynasty;
        uint256 endDynasty;
        bool exists; // This is good practice in solidity because the language sucks
    }

    address[] private availValidators;
    address[] private selectedValidators;
    uint256[] private dynastyCheckpoints;
    mapping(address => Validator) validatorInfo;

    constructor(
        TokenRegistry tr,
        uint256 _minStake,
        uint256 _unstakeDelay,
        address _owner
    ) public CustomOwnable(_owner) {

        publicStakeBank = new PublicStakeBank(tr, _minStake, _unstakeDelay);
    }

    /// Get current validator set (last enacted or initial if no changes ever made)
    function getValidators() public constant returns (address[]) {
        return selectedValidators;
    }

    function getStakeBankAddr () public view returns (address) {
        return publicStakeBank;
    }

    function incrementDynasty() {
        require( block.number > (dynastyCheckpoints[ dynastyCheckpoints.length-1 ] + dynastyInterval) );
        curDynasty++;
    }

    /// Called when an initiated change reaches finality and is activated.
    /// Only valid when msg.sender == SYSTEM (EIP96, 2**160 - 2)
    ///
    /// Also called when the contract is first enabled for consensus. In this case,
    /// the "change" finalized is the activation of the initial set.
    //function finalizeChange(bytes32 _seed) public onlyOwner { //onlySystemAndNotFinalized {
    function finalizeChange() public onlyOwner { //onlySystemAndNotFinalized {
        require( !finalized );
        bytes32 _seed = '0x0123';
        /* publicStakeBank.lock(); */

        var (stakerIds, balances) = publicStakeBank.totalBalances(); // can we do memory here?
        uint256[] memory stakerIndices = new uint256[](stakerIds.length);
        for (uint256 i = 1; i < stakerIndices.length; i++) {
            stakerIndices[i] = stakerIndices[i] + stakerIndices[i-1];
        }
        uint256 totalCoins = publicStakeBank.totalStaked(); // TODO: maybe use totalStakedAt(block.number)?

        selectedValidators = Fts.fts(_seed, stakerIds, balances, totalCoins, maxValidators);

        // TODO: Is this where we burn?

        /* publicStakeBank.unlock(); */

        finalized=true;
        emit ChangeFinalized(selectedValidators);
    }

    function withdraw(uint256 validatorIndex) public {
        // Only self-removal
        address valAddr = availValidators[ validatorIndex ];
        require(valAddr == msg.sender);

        // Remove info record
        delete validatorInfo[ valAddr ];

        // Remove only validator in list
        if (availValidators.length == 1) {
            availValidators.length--;
        } else {
            // Remove validator by swapping last in list
            address lastValidator   = availValidators[availValidators.length-1];
            availValidators[ validatorIndex ] = lastValidator;
            //delete validators[lastValidator]; // Remove duplicate
            availValidators.length--;
        }

        emit Withdraw(valAddr);
    }

    function deposit(uint256 amount, bytes tokenId) public {
        publicStakeBank.stakeFor(msg.sender, amount, tokenId);

        // Add validator to records
        uint256 newLength = availValidators.push( msg.sender );

        validatorInfo[ msg.sender ] = Validator({
            startDynasty: curDynasty,
            endDynasty: 1000000000000, // Change this to uint256 max
            exists: true
        });

        emit Deposit(msg.sender, newLength-1);
    }

    function isInValidatorSet(address validator) public view returns (bool) {
        // Check val info for efficiency
        Validator storage v = validatorInfo[ validator ];

        if (v.exists) return true;
        else return false;
    }

    // Reporting functions: operate on current validator set.
    // malicious behavior requires proof, which will vary by engine.

    function reportBenign(address validator, uint256 blockNumber) public {

    }

    function reportMalicious(address validator, uint256 blockNumber, bytes proof) public {

    }
}
