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
import './Lockable.sol';

/**
 * @title Contract for a validator set that has system params and modifiers and is seedable for RNG
 */
contract SystemValidatorSet is IValidatorSet, Lockable {
    event SystemValidatorError(string message);
    event Report(address indexed reporter, address indexed reported, bool indexed malicious);
    event Support(address indexed supporter, address indexed supported, bool indexed added);
    event ChangeFinalized(address[] current_set);

    // System address, used by the block sealer.
    address internal constant systemAddress = 0x00fffffffffffffffffffffffffffffffffffffffe;

    // Time after which the validators will report a validator as malicious.
    uint internal constant maxInactivity = 6 hours;

    // Ignore misbehaviour older than this number of blocks.
    uint internal constant recentBlocks = 20;

    // Number of blocks/epochs before a dynasty change occurs
    uint256 dynastyInterval = 1000;

    // Was the last validator change finalized.
    bool internal finalized;

    bytes32 public seed;

    function setSeed(bytes32 _seed) public onlyOwner onlyWhenUnlocked {
        seed = _seed;
    }

    function isInValidatorSet(address validator) public returns (bool);

    function isChangingDynasty() public returns (bool) {
        return (block.number % dynastyInterval) == 0;
    }

    modifier isRecent(uint blockNumber) {
        require(block.number <= blockNumber + recentBlocks);
        _;
    }

    modifier onlySystemAndNotFinalized() {
        require(msg.sender == systemAddress && !finalized);
        _;
    }

    modifier whenFinalized() {
        require(finalized);
        _;
    }
}
