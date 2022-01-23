// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


abstract contract AbstractPudu is ERC20 {

    function mint(address _address, uint amount) public virtual;
}