pragma solidity ^0.4.24;

import './IStakeBank.sol';


/**
 * @title Interface for stake banks that return all staker addresses and balances
 */
contract IPublicStakeBank is IStakeBank {
    function stakerBalances() public pure returns (address[], uint[]);
}
