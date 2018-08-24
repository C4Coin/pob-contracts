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
 * @title Library to help keep track of consortium voting
 */
library AddressVotes {
    // Tracks the number of votes from different addresses.
    struct Data {
        uint count;
        // Keeps track of who voted, prevents double vote.
        mapping(address => bool) inserted;
    }

    // Total number of votes cast.
    function count(Data storage self) public constant returns (uint) {
        return self.count;
    }

    // Did the voter already vote.
    function contains(Data storage self, address voter) public constant returns (bool) {
        return self.inserted[voter];
    }

    // Voter casts a vote.
    function insert(Data storage self, address voter) public {
        require( !self.inserted[voter] );

        self.count++;
        self.inserted[voter] = true;
        //return true;
    }

    // Retract a vote by a voter.
    function remove(Data storage self, address voter) public {
        require ( self.inserted[voter] );

        self.count--;
        self.inserted[voter] = false;
    }
}
