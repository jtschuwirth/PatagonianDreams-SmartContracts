// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Ticket is ERC721 {

    event NewTicket(uint ticketId);

    address contractOwner = msg.sender;

    string[] public tickets;

    constructor() ERC721("TCK", "Ticket") { 
    }

    modifier onlyOwner() {
        require(contractOwner == msg.sender);
        _;
    }

    function createTicket() public payable onlyOwner() {
        tickets.push("ticket");
        uint id = tickets.length - 1;
        _mint(msg.sender, id);
        emit NewTicket(id);
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        contractOwner = newOwner;
    }
}