// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract GameItems is ERC1155Upgradeable, AccessControlUpgradeable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public constant BasicRune = 0;
    uint256 public constant IntricateRune = 1;
    uint256 public constant PowerfullRune = 2;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function initialize() initializer public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _address, uint itemId, uint amount) public onlyRole(MINTER_ROLE) {
        _mint(_address, itemId, amount, "");
    }

    function burn(address from, uint id, uint amount) public onlyRole(BURNER_ROLE) {
        _burn(from, id, amount);
    }
}
