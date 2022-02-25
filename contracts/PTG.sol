// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract PTG is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    constructor(address gameDevAddress, address liquidityAddress, address foundingTeamAddress) ERC20("Patagonian Gem", "PTG") {
        _mint(gameDevAddress, 15000000*10**18);
        _mint(liquidityAddress, 7500000*10**18);
        _mint(foundingTeamAddress, 2500000*10**18);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _address, uint amount) public onlyRole(MINTER_ROLE) {
        require(1000000000*10**18 >= totalSupply()+amount);
        _mint(_address, amount);
    }

}