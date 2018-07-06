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


import "./IStakebank.sol";


/**
 * @title Interface for a stake bank which burns tokens
 */
contract IBurnableStakeBank is IStakeBank {
    event StakeBurned(address indexed user, uint256 amount, bytes data);

    function burn(address user, uint256 amount, bytes data) public;
    function burnAll(address user, bytes data) public;
}
