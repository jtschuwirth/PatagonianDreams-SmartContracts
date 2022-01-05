// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";

contract TicketSale is Pausable {

    event Sent(address indexed payee, uint256 amount, uint256 balance);
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

    address contractOwner = msg.sender;
    address tokenSeller;
    ERC721 public nftAddress;
    uint256 public currentPrice = 10*(10**18);

    constructor(address _nftAddress, address _tokenSeller) {
        require(_nftAddress != address(0) && _nftAddress != address(this));
        require(_tokenSeller != address(0) && _tokenSeller != address(this));
        tokenSeller = _tokenSeller;
        nftAddress = ERC721(_nftAddress);
    }

    modifier onlyOwner() {
        require(contractOwner == msg.sender);
        _;
    }

    function purchaseToken(uint256 _tokenId) public payable whenNotPaused {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice);
        require(nftAddress.ownerOf(_tokenId) == tokenSeller);
        nftAddress.safeTransferFrom(tokenSeller, msg.sender, _tokenId);
        emit Received(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function sendTo(address payable _payee, uint256 _amount) public onlyOwner {
        require(_payee != address(0) && _payee != address(this));
        require(_amount > 0 && _amount <= address(this).balance);
        _payee.transfer(_amount);
        emit Sent(_payee, _amount, address(this).balance);
    }

    function setCurrentPrice(uint256 _currentPrice) public onlyOwner {
        require(_currentPrice > 0);
        currentPrice = _currentPrice;
    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        contractOwner = newOwner;
    }
}