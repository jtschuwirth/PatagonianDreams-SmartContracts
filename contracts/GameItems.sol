// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract GameItems is ERC1155Upgradeable {

    address ContractOwner;
    address QuestContract;

    uint256 public constant BasicRune = 0;
    uint256 public constant IntricateRune = 1;
    uint256 public constant PowerfullRune = 2;

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
    }

    function mint(address _address, uint itemId, uint amount) public payable onlyQuestContract() {
        _mint(_address, itemId, amount, "");
    }


    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferQuestContract(address newQuestContract) public payable onlyOwner() {
        QuestContract = newQuestContract;
    }
}
