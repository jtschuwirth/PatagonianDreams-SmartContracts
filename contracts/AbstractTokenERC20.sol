// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract AbstractToken is ERC20 {
    function mint(address _address, uint amount) public virtual;

    function burn(address from, uint amount) public virtual;
}
