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

import './IValidatorSet.sol';

/**
 * @title Contract for a validator set that has params system params and modifiers
 */
contract SystemValidatorSet is IValidatorSet {
    /// Constants used by all validator sets
    // System address, used by the block sealer.
    address internal constant SYSTEM_ADDRESS = 0x00fffffffffffffffffffffffffffffffffffffffe;
    // Time after which the validators will report a validator as malicious.
    uint internal constant MAX_INACTIVITY = 6 hours;
    // Ignore misbehaviour older than this number of blocks.
    uint internal constant RECENT_BLOCKS = 20;
    // Was the last validator change finalized.
    bool internal finalized;

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
