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


import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import './interfaces/Lockable.sol';
import './interfaces/IBurnableStakeBank.sol';
import './interfaces/ConsensusToken.sol';


// @title Contract for to keep track of stake (checkpoint history total staked at block) and burn tokens
contract BurnableStakeBank is IBurnableStakeBank, Lockable {
    using SafeMath for uint256;

    struct Checkpoint {
        uint256 at;
        uint256 amount;
    }

    StandardBurnableToken public token;
    Checkpoint[] public stakeHistory;
    Checkpoint[] public burnHistory;
    uint256 public stakeLockBlockInterval = 1000;

    mapping (address => Checkpoint[]) public stakesFor;
    mapping (address => Checkpoint[]) public burnsFor;

    // @param _token Token that can be staked.
    constructor(ConsensusToken _token) public {
        require(address(_token) != 0x0);
        token = _token;
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
     * @notice Stakes a certain amount of tokens for another user.
     * @param user Address of the user to stake for.
     * @param amount Amount of tokens to stake.
     * @param __data Data field used for signalling in more complex staking applications. //stakeLockBlockInterval
     */
    function stakeFor(address user, uint256 amount, bytes __data) public onlyWhenUnlocked onlyWhenStakeInterval {
        updateCheckpointAtNow(stakesFor[user], amount, false);
        updateCheckpointAtNow(stakeHistory, amount, false);

        require(token.transferFrom(msg.sender, address(this), amount));
    }

    /**
     * @notice Burn an amount of tokens for user
     * @param user Address of the user to burn for.
     * @param burnAmount Amount of tokens to burn.
     * @param __data Data field used for signalling in more complex staking applications.
     * TODO: should we use onlyWhenUnlocked or onlySystemAndNotFinalized?
     * Likely use onlySystemAndNotFinalized at a higher-level not here.
     */
    function burnFor(address user, uint256 burnAmount, bytes __data) public onlyWhenUnlocked {
        require(totalStakedFor(user) >= burnAmount);

        // Burn tokens
        updateCheckpointAtNow(burnsFor[user], burnAmount, false);
        updateCheckpointAtNow(burnHistory, burnAmount, false);
        token.burn(burnAmount);

        // Remove stake
        updateCheckpointAtNow(stakesFor[user], burnAmount, true);
        updateCheckpointAtNow(stakeHistory, burnAmount, true);
    }

    /**
     * @notice Unstakes a certain amount of tokens.
     * @param amount Amount of tokens to unstake.
     * @param __data Data field used for signalling in more complex staking applications.
     */
    function unstake(uint256 amount, bytes __data) public onlyWhenStakeInterval {
        require(totalStakedFor(msg.sender) >= amount);

        updateCheckpointAtNow(stakesFor[msg.sender], amount, true);
        updateCheckpointAtNow(stakeHistory, amount, true);

        require(token.transfer(msg.sender, amount));
    }

    /**
     * @notice Returns total tokens staked for address.
     * @param addr Address to check.
     * @return amount of tokens staked.
     */
    function totalStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].amount;
    }

    /**
     * @notice Returns total tokens staked.
     * @return amount of tokens staked.
     */
    function totalStaked() public view returns (uint256) {
        return totalStakedAt(block.number);
    }

    /**
     * @notice Returns true if history related functions are implemented.
     * @return Bool Are history related functions implemented?
     */
    function supportsHistory() public pure returns (bool) {
        return true;
    }

    /**
     * @notice Returns the token address.
     * @return Address of token.
     */
    function token() public view returns (address) {
        return token;
    }

    /**
     * @notice Returns last block address staked at.
     * @param addr Address to check.
     * @return block number of last stake.
     */
    function lastStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].at;
    }

    /**
     * @notice Returns total amount of tokens staked at block for address.
     * @param addr Address to check.
     * @param blockNumber Block number to check.
     * @return amount of tokens staked.
     */
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakesFor[addr], blockNumber);
    }

    /**
     * @notice Returns the total tokens staked at block.
     * @param blockNumber Block number to check.
     * @return amount of tokens staked.
     */
    function totalStakedAt(uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakeHistory, blockNumber);
    }

    /**
     * @notice Updates the last element of the checkpoint history with amount staked or unstaked
     * @param history Checkpoint state array which stores a block number and amount
     * @param amount Amount of tokens to stake or unstake
     * @param isUnstake flag to represent whether to remove staked amount in checkpoint
     */
    function updateCheckpointAtNow(Checkpoint[] storage history, uint256 amount, bool isUnstake) internal {
        uint256 length = history.length;
        if (length == 0) {
            history.push(Checkpoint({at: block.number, amount: amount}));
            return;
        }

        // Create new checkpoint for block containing latest stake amount
        if (history[length-1].at < block.number) {
            history.push(Checkpoint({at: block.number, amount: history[length-1].amount}));
        }

        // Add/sub the difference in stake to new checkpoint
        Checkpoint storage checkpoint = history[length];

        if (isUnstake) {
            checkpoint.amount = checkpoint.amount.sub(amount);
        } else {
            checkpoint.amount = checkpoint.amount.add(amount);
        }
    }

    /**
     * @notice Gets amount staked given a checkpoint history and the block number
     * @param history Checkpoint state array which stores a block number and amount
     * @param blockNumber the block number at which a previous stake was set
     */
    function stakedAt(Checkpoint[] storage history, uint256 blockNumber) internal view returns (uint256) {
        uint256 length = history.length;

        if (length == 0 || blockNumber < history[0].at) {
            return 0;
        }

        if (blockNumber >= history[length-1].at) {
            return history[length-1].amount;
        }

        uint min = 0;
        uint max = length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (history[mid].at <= blockNumber) {
                min = mid;
            } else {
                max = mid-1;
            }
        }

        return history[min].amount;
    }

    /**
     * @notice Allow only when block is not a "stakeLockBlockInterval" number of blocks
     */
    modifier onlyWhenStakeInterval() {
        require(block.number % stakeLockBlockInterval != 0);
        _;
    }
}
