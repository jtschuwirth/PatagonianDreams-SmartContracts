// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract GameItems is ERC1155Upgradeable, AccessControlUpgradeable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant BasicRune = 0;
    uint256 public constant IntricateRune = 1;
    uint256 public constant PowerfullRune = 2;

    function initialize() initializer public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _address, uint itemId, uint amount) public payable onlyRole(MINTER_ROLE) {
        _mint(_address, itemId, amount, "");
    }
}
}
