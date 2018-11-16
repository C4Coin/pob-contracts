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


import './interfaces/IPublicStakeBank.sol';
import './DelayedStakeBank.sol';
import './TokenRegistry.sol';

/**
 * @title Contract for the public facing stake bank implementation.
 * @notice Used to set values for delay and also used by public validator contract for burning.
 */
contract PublicStakeBank is IPublicStakeBank, DelayedStakeBank {
    constructor(
        TokenRegistry tr,
        uint256 _minStake,
        uint256 _unstakeDelay) public DelayedStakeBank(tr, _minStake, _unstakeDelay) {
    }
}
