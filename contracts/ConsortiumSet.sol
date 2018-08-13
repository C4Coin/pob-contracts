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
import './libraries/AddressVotes.sol';
import './InitialConsortiumSet.sol';


/**
 * @title Contract for consortium validators to add and remove support to addresses
 * @notice Support can not be added once MAX_VALIDATORS are present.
 * @notice Addresses supported by more than half of the existing validators are the validators.
 * @notice Malicious behaviour causes support removal.
 * @notice Benign misbehaviour causes supprt removal if its called again after MAX_INACTIVITY.
 * @notice Benign misbehaviour can be absolved before being called the second time.
 */
contract ConsortiumSet is IValidatorSet, InitialConsortiumSet {
    event Report(address indexed reporter, address indexed reported, bool indexed malicious);
    event Support(address indexed supporter, address indexed supported, bool indexed added);
    event ChangeFinalized(address[] current_set);

    struct ValidatorStatus {
        bool isValidator;

        // Index in the validatorList.
        uint index;

        // Validator addresses which supported the address.
        AddressVotes.Data support;

        // Keeps track of the votes given out while the address is a validator.
        address[] supported;

        // Initial benign misbehaviour time tracker.
        mapping(address => uint) firstBenign;

        // Repeated benign misbehaviour counter.
        AddressVotes.Data benignMisbehaviour;
    }

    // STATE
    // Support can not be added once this number of validators is reached.
    uint internal constant MAX_VALIDATORS = 30;

    // Current list of addresses entitled to participate in the consensus.
    address[] private validatorsList;
    // Was the last validator change finalized.
    bool private finalized;
    // Tracker of status for each address.
    mapping(address => ValidatorStatus) private validatorsStatus;

    // Used to lower the constructor cost.
    AddressVotes.Data private initialSupport;

    /**
     * Each validator is initially supported by all others.
     * pendingList should be populated in InitialSet.sol and used here.
     */
    constructor() public {
        initialSupport.count = pendingList.length;
        for (uint i = 0; i < pendingList.length; i++) {
            address supporter = pendingList[i];
            initialSupport.inserted[supporter] = true;
        }

        for (uint j = 0; j < pendingList.length; j++) {
            address validator = pendingList[j];
            validatorsStatus[validator] = ValidatorStatus({
                isValidator: true,
                index: j,
                support: initialSupport,
                supported: pendingList,
                benignMisbehaviour: AddressVotes.Data({ count: 0 })
            });
        }
        validatorsList = pendingList;
    }

    // @notice Called on every block to update node validator list.
    function getValidators() public constant returns (address[]) {
        return validatorsList;
    }

    // @notice called when a round is finalized by engine
    function finalizeChange() public onlySystemAndNotFinalized {
        validatorsList = pendingList;
        finalized = true;
        emit ChangeFinalized(validatorsList);
    }

    // SUPPORT LOOKUP AND MANIPULATION
    // @notice Find the total support for a given address.
    function getSupport(address validator) public constant returns (uint) {
        return AddressVotes.count(validatorsStatus[validator].support);
    }

    // @notice Find addresses supporting this validator
    function getSupported(address validator) public constant returns (address[]) {
        return validatorsStatus[validator].supported;
    }

    // @notice Vote to include a validator.
    function addSupport(address validator) public onlyValidator notVoted(validator) freeValidatorSlots {
        newStatus(validator);
        AddressVotes.insert(validatorsStatus[validator].support, msg.sender);
        validatorsStatus[msg.sender].supported.push(validator);
        addValidator(validator);
        emit Support(msg.sender, validator, true);
    }

    // ENACTMENT FUNCTIONS (called when support gets out of line with the validator list)
    /**
     * @notice Add the validator if supported by majority.
     * @notice Since the number of validators increases it is possible to some fall below the threshold.
     */
    function addValidator(address validator) public isNotValidator(validator) hasHighSupport(validator) {
        validatorsStatus[validator].index = pendingList.length;
        pendingList.push(validator);
        validatorsStatus[validator].isValidator = true;
        // New validator should support itself.
        AddressVotes.insert(validatorsStatus[validator].support, validator);
        validatorsStatus[validator].supported.push(validator);
        initiateChange();
    }

    /**
     * @notice Remove a validator without enough support.
     * @notice Can be called to clean low support validators after making the list longer.
     */
    function removeValidator(address validator) public isValidator(validator) hasLowSupport(validator) {
        uint removedIndex = validatorsStatus[validator].index;
        // Can not remove the last validator.
        uint lastIndex = pendingList.length-1;
        address lastValidator = pendingList[lastIndex];
        // Override the removed validator with the last one.
        pendingList[removedIndex] = lastValidator;
        // Update the index of the last validator.
        validatorsStatus[lastValidator].index = removedIndex;
        // Remove last validator
        pendingList.length--;
        // Reset validator status.
        validatorsStatus[validator].index = 0;
        validatorsStatus[validator].isValidator = false;
        // Remove all support given by the removed validator.
        address[] storage toRemove = validatorsStatus[validator].supported;
        for (uint i = 0; i < toRemove.length; i++) {
            removeSupport(validator, toRemove[i]);
        }
        delete validatorsStatus[validator].supported;
        initiateChange();
    }

    // MODIFIERS
    // @notice Determine if a majority supports this validator
    function highSupport(address validator) public constant returns (bool) {
        return getSupport(validator) > pendingList.length/2;
    }

    // @notice Update validator status with benign report address
    function firstBenignReported(address reporter, address validator) public constant returns (uint) {
        return validatorsStatus[validator].firstBenign[reporter];
    }

    // MALICIOUS BEHAVIOUR HANDLING
    /**
     * @notice Called when a validator should be removed
     * @notice The proof bytes are not yet implemented
     */
    function reportMalicious(address validator, uint blockNumber, bytes) public onlyValidator isRecent(blockNumber) {
        removeSupport(msg.sender, validator);
        emit Report(msg.sender, validator, true);
    }

    // BENIGN MISBEHAVIOUR HANDLING
    // @notice Report that a validator has misbehaved in a benign way.
    function reportBenign(
        address validator,
        uint blockNumber)
    public onlyValidator isValidator(validator) isRecent(blockNumber) {
        firstBenign(validator);
        repeatedBenign(validator);
        emit Report(msg.sender, validator, false);
    }

    // @notice Find the total number of repeated misbehaviour votes.
    function getRepeatedBenign(address validator) public constant returns (uint) {
        return AddressVotes.count(validatorsStatus[validator].benignMisbehaviour);
    }

    // @notice Vote to remove support for a validator.
    function removeSupport(address sender, address validator) private {
        require(AddressVotes.remove(validatorsStatus[validator].support, sender));
        emit Support(sender, validator, false);
        // Remove validator from the list if there is not enough support.
        removeValidator(validator);
    }

    // @notice Log desire to change the current list.
    function initiateChange() private whenFinalized {
        finalized = false;
        emit InitiateChange(blockhash(block.number - 1), pendingList);
    }

    // @notice Track the first benign misbehaviour.
    function firstBenign(address validator) private hasNotBenignMisbehaved(validator) {
        validatorsStatus[validator].firstBenign[msg.sender] = now;
    }

    // @notice Report that a validator has been repeatedly misbehaving.
    function repeatedBenign(address validator) private hasRepeatedlyBenignMisbehaved(validator) {
        AddressVotes.insert(validatorsStatus[validator].benignMisbehaviour, msg.sender);
        confirmedRepeatedBenign(validator);
    }

    // @notice When enough long term benign misbehaviour votes have been seen, remove support.
    function confirmedRepeatedBenign(address validator) private agreedOnRepeatedBenign(validator) {
        validatorsStatus[validator].firstBenign[msg.sender] = 0;
        AddressVotes.remove(validatorsStatus[validator].benignMisbehaviour, msg.sender);
        removeSupport(msg.sender, validator);
    }

    // @notice Absolve a validator from a benign misbehaviour.
    function absolveFirstBenign(address validator) private hasBenignMisbehaved(validator) {
        validatorsStatus[validator].firstBenign[msg.sender] = 0;
        AddressVotes.remove(validatorsStatus[validator].benignMisbehaviour, msg.sender);
    }

    // PRIVATE UTILITY FUNCTIONS
    // @notice Add a status tracker for unknown validator.
    function newStatus(address validator) private hasNoVotes(validator) {
        validatorsStatus[validator] = ValidatorStatus({
            isValidator: false,
            index: pendingList.length,
            support: AddressVotes.Data({ count: 0 }),
            supported: new address[](0),
            benignMisbehaviour: AddressVotes.Data({ count: 0 })
        });
    }

    modifier hasHighSupport(address validator) {
        if (highSupport(validator)) { _; }
    }

    modifier hasLowSupport(address validator) {
        if (!highSupport(validator)) { _; }
    }

    modifier hasNotBenignMisbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) == 0) { _; }
    }

    modifier hasBenignMisbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) > 0) { _; }
    }

    modifier hasRepeatedlyBenignMisbehaved(address validator) {
        if (firstBenignReported(msg.sender, validator) - now > MAX_INACTIVITY) { _; }
    }

    modifier agreedOnRepeatedBenign(address validator) {
        if (getRepeatedBenign(validator) > pendingList.length/2) { _; }
    }

    modifier freeValidatorSlots() {
        require(pendingList.length < MAX_VALIDATORS);
        _;
    }

    modifier onlyValidator() {
        require(validatorsStatus[msg.sender].isValidator);
        _;
    }

    modifier isValidator(address someone) {
        if (validatorsStatus[someone].isValidator) { _; }
    }

    modifier isNotValidator(address someone) {
        if (!validatorsStatus[someone].isValidator) { _; }
    }

    modifier notVoted(address validator) {
        require(!AddressVotes.contains(validatorsStatus[validator].support, msg.sender));
        _;
    }

    modifier hasNoVotes(address validator) {
        if (AddressVotes.count(validatorsStatus[validator].support) == 0) { _; }
    }

    modifier isRecent(uint blockNumber) {
        require(block.number <= blockNumber + RECENT_BLOCKS);
        _;
    }

    modifier onlySystemAndNotFinalized() {
        require(msg.sender == SYSTEM_ADDRESS && !finalized);
        _;
    }

    modifier whenFinalized() {
        require(finalized);
        _;
    }
}
