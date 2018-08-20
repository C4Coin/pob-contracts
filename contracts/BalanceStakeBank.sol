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


import './BurnableStakeBank.sol';
import './TokenRegistry.sol';

/**
 * @title Contract for a stake bank that can compute total balances
 * @notice Contract keeps stakers sorted by address to easily select a staker fairly
 */
contract BalanceStakeBank is BurnableStakeBank {
    // Staker and staker balance
    struct StakeData {
        uint amount;
        address staker;
    }

    // Doubly-linked list of nodes containing stake data
    struct Node {
        StakeData data;
        uint prev;
        uint next;
    }

    // Array of all current stake nodes
    Node[] internal stakeNodes;

    uint public numStakers;

    // Keep track of whether an address that is staking is sorted
    mapping (address => bool) public isSorted;

    /**
     * @param _tokenRegistry Token registry that contains white listed tokens.
     * @param _minimumStake Min threshold of amount that can be staked.
     */
    constructor(TokenRegistry _tokenRegistry, uint256 _minimumStake) public BurnableStakeBank(_tokenRegistry, _minimumStake) {
        StakeData memory temp = StakeData({ amount: 0, staker: address(0) });
        stakeNodes.push(Node(temp, 0, 0));
    }

    /**
     * @notice Calls StakeBank.stake after updating staker index
     * @param amount Amount of tokens to stake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function stake(uint256 amount, bytes data) public {
        stakeFor(msg.sender, amount, data);
    }

    /**
     * @notice Stakes using BurnableStakeBank and updates nodes by address
     * @dev Overrides BurnableStakeBank.stakeFor
     * @param user Address of the user to stake for.
     * @param amount Amount of tokens to stake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function stakeFor(address user, uint256 amount, bytes data) public {
        BurnableStakeBank.stakeFor(user, amount, data);
        updateNodesByAddress(user);
        emit Staked(user, amount, totalStakedFor(user), data);
    }

    /**
     * @notice Burns using BurnableStakeBank and updates nodes by address
     * @dev Overrides BurnableStakeBank.stakeFor
     * @param burnAmount Amount of tokens to burn.
     * @param __data Data field used for signalling in more complex staking applications.
     */
    function burnFor(address user, uint256 burnAmount, bytes __data) public onlyOwner {
        BurnableStakeBank.burnFor(user, burnAmount, __data);
        updateNodesByAddress(user);
        emit StakeBurned(user, burnAmount, __data);
    }

    /**
     * @notice Unstakes using BurnableStakeBank and updates nodes by address
     * @dev Overrides BurnableStakeBank.unstake
     * @param amount Amount of tokens to unstake.
     * @param data Data field used for signalling in more complex staking applications.
     */
    function unstake(uint256 amount, bytes data) public {
        BurnableStakeBank.unstake(amount, data);
        updateNodesByAddress(msg.sender);
        emit Unstaked(msg.sender, amount, totalStakedFor(msg.sender), data);
    }

    // @notice Retrieves balance for each staked address in stake nodes
    function totalBalances() public view returns (address[], uint[]) {
        address[] memory stakers = new address[](numStakers);
        uint[] memory amounts = new uint[](numStakers);
        uint current = stakeNodes[0].next;
        for (uint i; i < numStakers; i++) {
            stakers[i] = stakeNodes[current].data.staker;
            amounts[i] = stakeNodes[current].data.amount;
            current = stakeNodes[current].next;
        }
        return (stakers, amounts);
    }

    /**
     * @notice Update stake nodes such that it stays sorted using the staker's address
     * @param _staker Address of the staker used to update stake nodes array
     */
    function updateNodesByAddress(address _staker) internal {
        uint newStakedAmount = BurnableStakeBank.totalStakedFor(_staker);
        if (newStakedAmount == 0) {
            isSorted[_staker] = false;
            removeStakerFromArray(_staker);
        } else if (isSorted[_staker]) {
            removeStakerFromArray(_staker);
            insertAddressSortedNode(_staker, newStakedAmount);
        } else {
            isSorted[_staker] = true;
            insertAddressSortedNode(_staker, newStakedAmount);
        }
    }

    /**
     * @notice Insert node sorted by staker address
     * @param staker Address of staker which is being updated.
     * @param amount Amount of tokens staked by staker.
     */
    function insertAddressSortedNode(address staker, uint amount) internal returns (uint) {
        uint current = stakeNodes[0].next;
        if (current == 0) return insertNodeAfter(0, staker, amount);
        while (isValidNode(current)) {
            if (staker > stakeNodes[current].data.staker) {
                break;
            }
            current = stakeNodes[current].next;
        }
        return insertNodeBefore(current, staker, amount);
    }

    // @notice Given a staker address find and remove that staker from the staker nodes
    function removeStakerFromArray(address _staker) internal {
        uint id = searchNode(_staker);
        require(id > 0);
        removeNode(id);
    }

    // @notice Find a node by address in the stake nodes
    function searchNode(address staker) internal view returns (uint) {
        uint current = stakeNodes[0].next;
        while (isValidNode(current)) {
            if (staker == stakeNodes[current].data.staker) {
                return current;
            }
            current = stakeNodes[current].next;
        }
        return 0;
    }

    // @notice Insert a node with its stake amount after an index in stake nodes.
    function insertNodeAfter(uint id, address staker, uint amount) internal returns (uint newID) {
        // 0 is allowed here to insert at the beginning.
        require(id == 0 || isValidNode(id));

        Node storage node = stakeNodes[id];

        stakeNodes.push(Node({
            data: StakeData(amount, staker),
            prev: id,
            next: node.next
        }));

        newID = stakeNodes.length - 1;

        stakeNodes[node.next].prev = newID;
        node.next = newID;
        numStakers++;
    }

    // @notice Insert a staker and its stake before an index in the stake nodes
    function insertNodeBefore(uint id, address staker, uint amount) internal returns (uint) {
        return insertNodeAfter(stakeNodes[id].prev, staker, amount);
    }

    // @notice Remove a node from the stake nodes by deleting array item and repointing prev. and next
    function removeNode(uint id) internal {
        require(isValidNode(id));

        Node storage node = stakeNodes[id];

        stakeNodes[node.next].prev = node.prev;
        stakeNodes[node.prev].next = node.next;

        delete stakeNodes[id];
        numStakers--;
    }

    // @notice A valid node is the head or has a previous node.
    function isValidNode(uint id) internal view returns (bool) {
        // 0 is a sentinel and therefore invalid.
        return id != 0 && (id == stakeNodes[0].next || stakeNodes[id].prev != 0);
    }
}
