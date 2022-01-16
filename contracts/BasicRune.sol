// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract BasicRune is ERC721Upgradeable {
    function initialize() initializer public {
        __ERC721_init("Basic Rune", "BaRune");
    }
}