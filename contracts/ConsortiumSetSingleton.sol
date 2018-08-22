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


import './ConsortiumSet.sol';
import './ChainSpec.sol';

/**
 * @title Library to access singleton consortium validator set
 */
library ConsortiumSetSingleton {
    //ConsortiumSet private _consortiumSet;// = new ConsortiumSet();

    /*
    function specInstance() public constant returns (ConsortiumSet) {
       require( ChainSpec.isEnabled() );
       return ConsortiumSet( CainSpec.addrOf(keccack256("ConsortiumSet")) );
    }
    */
    function instance(address[] pendingList, address _owner) public returns (ConsortiumSet) {
        if (ChainSpec.isEnabled()) {
            return ConsortiumSet(ChainSpec.addrOf(keccak256("ConsortiumSet")));
        }
        else {
            // Initialize if it hasn't been yet
            //if ( address(_consortiumSet) == 0x0 )
               //_consortiumSet = new ConsortiumSet(pendingList);

            //return _consortiumSet;
            return new ConsortiumSet(pendingList, _owner);
        }
    }
}
