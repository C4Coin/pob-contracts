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


import './BalanceStakeBank.sol';


/**
 * @title Contract for a stake bank implementing a stake and unstake delay
 */
contract DelayedStakeBank is BalanceStakeBank {
    uint256 private unstakeDelay;

    // Balance of last amount staked for a staker
    mapping (address => uint256) private lastStaked;

    /**
     * @param _token Token that can be staked.
     * @param _unstakeDelay Earliest time (s) after last stake that stake can be withdrawn
     */
    constructor(IBurnableERC20 _token, uint256 _unstakeDelay) public BalanceStakeBank(_token) {
        unstakeDelay = _unstakeDelay;
    }

    /**
     * @notice Stakes a certain amount of tokens.
     * @param amount Amount of tokens to stake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function stake(uint256 amount, bytes data) public {
        stakeFor(msg.sender, amount, data);
    }

    /**
     * @notice Overrides IndexedStakeBank.stakeFor, to prevent denial of service
     * @param user Address of the user to stake for.
     * @param amount Amount of tokens to stake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function stakeFor(address user, uint256 amount, bytes data) public {
        require(user == msg.sender);
        lastStaked[msg.sender] = block.number;
        BalanceStakeBank.stakeFor(user, amount, data);
    }

    /**
     * @notice Unstakes a certain amount of tokens, if delay has passed.
     * @dev Overrides StakeBank.unstake
     * @param amount Amount of tokens to unstake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function unstake(uint256 amount, bytes data) public {
        require(block.number >= lastStaked[msg.sender].add(unstakeDelay));
        BalanceStakeBank.unstake(amount, data);
    }
}
