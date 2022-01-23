// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Pudu is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("Pudu", "PUDU") {
        _mint(msg.sender, 20000000*10**18);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _address, uint amount) public payable onlyRole(MINTER_ROLE) {
        require(1000000000*10**18 >= totalSupply()+amount);
        _mint(_address, amount);
    }

}