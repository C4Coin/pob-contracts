/// Implementation based on Melonport - Include licensing
pragma solidity ^0.4.23;

import "./StakeBank.sol";


contract IndexedStakeBank is Stakebank {
    struct StakeData {
        uint amount;
        address staker;
    }

    struct Node {
        StakeData data;
        uint prev;
        uint next;
    }

    Node[] internal stakeNodes;
    uint public numStakers;

    /// @param _token Token that can be staked.
    constructor(ERC20 _token) StakeBank(_token) public {
        StakeData memory temp = StakeData({ amount: 0, staker: address(0) });
        stakeNodes.push(Node(temp, 0, 0));
    }

    /// @notice Wraps StakeBank.stake
    /// @param amount Amount of tokens to stake.
    /// @param data Data field used for signalling in more complex staking applications.
    function stake(uint256 amount, bytes data) public {
        StakeBank.stakeFor(msg.sender, amount, data);
    }

    /// @notice Wraps StakeBank.stakeFor
    /// @param user Address of the user to stake for.
    /// @param amount Amount of tokens to stake.
    /// @param data Data field used for signalling in more complex staking applications.
    function stakeFor(address user, uint256 amount, bytes data) public {
        StakeBank.stakeFor(user, amount, data);
    }

    /// @notice Wraps StakeBank unstake
    /// @dev Overrides StakeBank.unstake
    /// @param amount Amount of tokens to unstake.
    /// @param data Data field used for signalling in more complex staking applications.
    function unstake(uint256 amount, bytes data) public {
        StakeBank.unstake(amount, data);
    }
}
