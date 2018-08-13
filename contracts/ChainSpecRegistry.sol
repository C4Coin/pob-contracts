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


library ChainSpecRegistry {
    function indexOf(bytes32 contractHash) pure returns (address) {
        // Built-in chainspec contracts start at offset
        uint256 offset = 0x100;

        // TODO: Add secret sharing contracts
        bytes32[6] memory _contractHashes = [
            keccak256("CommitteeSet"),
            keccak256("ConsortiumSet"),
            keccak256("PublicSet"),
            keccak256("PublicStakeBank"),
            keccak256("TokenRegistry"),
            keccak256("BlockReward")
        ];

        for (uint256 i=0; i < _contractHashes.length; i++) {
            if (contractHash == _contractHashes[i]) {
                return address((i + offset));
            }
        }
        throw;
    }
}
