//! TODO: Determine dual licensing for this project
//! since HarbourProject uses GPLv3 and parity contacts use Apache.
//! https://softwareengineering.stackexchange.com/questions/197710/how-to-use-gpl-v3-with-apache-license-2-0

pragma solidity ^0.4.23;

import "./IndexedStakeBank.sol";


contract DelayedStakeBank is IndexedStakeBank {
    uint256 unstakeDelay;
    mapping (address => uint256) lastStaked;

    /// @param _token Token that can be staked.
    /// @param _unstakeDelay Earliest time (s) after last stake that stake can be withdrawn
    constructor(ERC20 _token, uint256 _unstakeDelay) IndexedStakeBank(_token) public {
        unstakeDelay = _unstakeDelay;
    }

    /// @notice Stakes a certain amount of tokens.
    /// @param amount Amount of tokens to stake.
    /// @param data Data field used for signalling in more complex staking applications.
    function stake(uint256 amount, bytes data) public {
        stakeFor(msg.sender, amount, data);
    }

    /// @notice Overrides IndexedStakeBank.stakeFor, to prevent denial of service
    /// @param user Address of the user to stake for.
    /// @param amount Amount of tokens to stake.
    /// @param data Data field used for signalling in more complex staking applications.
    function stakeFor(address user, uint256 amount, bytes data) public {
        require(user == msg.sender);
        lastStaked[msg.sender] = block.number;
        IndexedStakeBank.stakeFor(user, amount, data);
    }

    /// @notice Unstakes a certain amount of tokens, if delay has passed.
    /// @dev Overrides StakeBank.unstake
    /// @param amount Amount of tokens to unstake.
    /// @param data Data field used for signalling in more complex staking applications.
    function unstake(uint256 amount, bytes data) public {
        require(block.number >= lastStaked[msg.sender].add(unstakeDelay));
        IndexedStakeBank.unstake(amount, data);
    }
}
