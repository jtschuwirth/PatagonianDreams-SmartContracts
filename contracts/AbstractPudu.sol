// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

abstract contract AbstractPudu {

    function mint(address _address, uint amount) public virtual;

    function balanceOf(address _address) public view virtual returns (uint);

    function totalSupply() public view virtual returns (uint);
}