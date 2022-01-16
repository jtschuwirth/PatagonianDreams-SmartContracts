// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract BasicRune is ERC721Upgradeable {

    address ContractOwner;
    address QuestContract;

    uint[] public basicRunes;

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    modifier onlyQuestContract() {
        require(QuestContract == msg.sender);
        _;
    }

    function initialize() initializer public {
        ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
        QuestContract = address(0);
        __ERC721_init("Basic Rune", "BaRune");
    }

    function mint(address _address) public payable onlyQuestContract() {
        uint id = basicRunes.length;
        basicRunes.push(id);
        _mint(_address, id);
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferQuestContract(address newQuestContract) public payable onlyOwner() {
        QuestContract = newQuestContract;
    }
}