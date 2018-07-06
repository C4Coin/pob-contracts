pragma solidity ^0.4.24;

import "./IStakeBank.sol";


/**
 * @title Interface for stake banks that return address balances
 * @notice Gives deriving contracts design by contract modifiers
 */
contract IBalanceStakeBank is IStakeBank {
    function totalBalances() public constant returns (address[], uint[]);
}
