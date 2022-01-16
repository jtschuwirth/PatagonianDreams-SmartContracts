// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

abstract contract AbstractGameItems is ERC1155 {

    function mint(address _address, uint itemId, uint amount) public virtual;

    function transferOwnership(address newOwner) public virtual;

    function transferQuestContract(address newQuestContract) public virtual;
}