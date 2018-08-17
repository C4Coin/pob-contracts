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


/**
 * @title Interface for a stake bank based on EIP900 standard with extra method for getting balances
 */
contract IStakeBank {
    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, bytes data) public;
    function stakeFor(address user, uint256 amount, bytes data) public;
    function unstake(uint256 amount, bytes data) public;
    function totalStakedFor(address addr) public view returns (uint256);
    function totalStaked() public view returns (uint256);
    function token() public view returns (address);
    function supportsHistory() public pure returns (bool);
    function lastStakedFor(address addr) public view returns (uint256);
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256);
    function totalStakedAt(uint256 blockNumber) public view returns (uint256);

    function totalBalances() public view returns (address[], uint[]);
}
