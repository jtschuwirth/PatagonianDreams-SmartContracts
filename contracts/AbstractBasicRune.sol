// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract AbstractBasicRune is ERC721 {

    function mint(address _address) public virtual;

    function transferOwnership(address newOwner) public virtual;

    function transferQuestContract(address newQuestContract) public virtual;
}