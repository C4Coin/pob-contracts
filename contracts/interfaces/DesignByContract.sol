pragma solidity ^0.4.23;

/// @title Desing by contract (Hoare logic)
/// @notice Gives deriving contracts design by contract modifiers
contract DBC {
    modifier pre_cond(bool condition) {
        require(condition);
        _;
    }

    modifier post_cond(bool condition) {
        _;
        assert(condition);
    }

    modifier invariant(bool condition) {
        require(condition);
        _;
        assert(condition);
    }
}
