// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract Pudu is ERC20 {

    address ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
    address QuestAddress = address(0);

    constructor() ERC20("Pudu", "PUDU") {
        _mint(ContractOwner, 20000000*10**18);
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    modifier onlyQuestContract() {
        require(QuestAddress == msg.sender);
        _;
    }

    function mint(address _address, uint amount) public payable onlyQuestContract() {
        require(1000000000 >= totalSupply()+amount);
        _mint(_address, amount);
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferQuestAddress(address newQuest) public payable onlyOwner() {
        QuestAddress = newQuest;
    }
}