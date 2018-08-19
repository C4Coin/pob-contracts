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
 * @title Follow-the-Satoshi library selects stakers with a random seed based on coin ownership
 */
library Fts {
   event Debug(uint256 x);

   function _newRandomNumber(bytes32 seed) internal returns (uint256) {
      return uint256( keccak256(seed) );
   }

   function fts (
       bytes32 seed,
       address[] stakerIds,
       uint256[] stakerIndices,
       uint256 totalCoins,
       uint256 numBlocks) public returns (address[])
   {
       require(stakerIds.length+1 == stakerIndices.length);

       address[] memory selectedStakers = new address[](numBlocks);

       // Generate a random index
       uint256 rndIndex = _newRandomNumber(seed) % totalCoins;

       // Select a staker for each block
       for (uint256 i = 0; i < numBlocks; i++)
       {
          // Generate new random index for subsequent passes
          if (i != 0) rndIndex = _newRandomNumber( bytes32(rndIndex) ) % totalCoins;

          // Match staker using a binary search
          uint min = 0;
          uint max = stakerIndices.length;

          while (max > min) {
             uint mid = (max + min + 1) / 2;
             if (stakerIndices[mid] <= rndIndex) {
                 min = mid;
             } else {
                 max = mid-1;
             }
          }
          selectedStakers[i] = stakerIds[min];
       }
       
       return selectedStakers;
   }
}
