pragma solidity ^0.4.24;

contract Fts {
   function _newRandomNumber(bytes32 seed) internal returns (uint256) {
      return uint256( keccak256(seed) );
   }

   function fts (
       bytes32 seed,
       address[] stakerIds,
       uint256[] stakerIndices,
       uint256 totalCoin) public returns (address)
   {
       require(stakerIds.length == stakerIndices.length);

       // Generate a random index
       uint256 rndIndex  = _newRandomNumber(seed) % totalCoin;

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

       return stakerIds[min];
   }
}
