// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {

    address ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
    address TestAddress = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
    address TreasuryAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;

    constructor() ERC20("Token Patagonia Test", "TPT") {
        _mint(TestAddress, 100*10**18);
        _mint(TreasuryAddress, 4000000*10**18);
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }
}