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


interface IBurnableERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender)
    public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value)
    public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

    event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
    );

    event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
    );
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public;
    function burnFrom(address _from, uint256 _value) public;
}
