pragma solidity ^0.4.24;

library FtsLib {
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
