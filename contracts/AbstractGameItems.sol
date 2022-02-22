// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

abstract contract AbstractGameItems is ERC1155Upgradeable {

    function mint(address _address, uint itemId, uint amount) public virtual;

    function burn(address from, uint id, uint amount) public virtual;
}