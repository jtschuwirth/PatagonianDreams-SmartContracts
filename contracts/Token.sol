// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Token is ERC20 {

    address contractOwner = msg.sender;
    address TestAddress = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;

    constructor() ERC20("Token Patagonia Test", "TPT") {
        _mint(TestAddress, 4000000*10**18);
    }

    modifier onlyOwner() {
        require(contractOwner == msg.sender);
        _;
    }

    function mint(address _address, uint _funds) public payable onlyOwner() {
        _mint(_address, _funds);
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        contractOwner = newOwner;
    }
}