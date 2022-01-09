// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tree is ERC721 {
    event NewTree(uint treeId);
    event GainExp(uint treeId, uint amount);
    event GainLevel(uint treeId);

    uint Nonce = 1;
    uint Digits = 16;
    uint Modulus = 10 ** Digits;
    address ContractOwner = msg.sender;
    address Token = 0x70b3F9216A1600268146efC35944Efb376F4c4fc;

    struct TreeStruct {
        uint treeDNA;
        uint level;
        uint exp;
        bool inMission;
    }

    TreeStruct[] public trees;

    constructor() ERC721("TREE", "Tree") { 
    }

    modifier onlyOwnerOf(uint _treeId) {
        require(ownerOf(_treeId) == msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    function gainExp(uint treeId, uint amount) public payable onlyOwnerOf(treeId) {
        //Cambiar a que solo lo pueda hacer el contrato de quests y no el usuario
        trees[treeId].exp = trees[treeId].exp + amount;
        emit GainExp(treeId, amount);
    }

    function neededExp(uint treeId) public view returns (uint) {
        return trees[treeId].level*100;
    }

    function neededAmount(uint treeId) public view returns (uint) {
        return (trees[treeId].level*1)*10**18;
    }

    function gainLevel(uint treeId) public payable onlyOwnerOf(treeId) {
        uint Exp = neededExp(treeId);
        uint amount = neededAmount(treeId);
        require(trees[treeId].exp >= Exp);
        IERC20(Token).transferFrom(msg.sender, address(this), amount);
        trees[treeId].exp = trees[treeId].exp-Exp;
        trees[treeId].level++;
        emit GainLevel(treeId);
    }

    function currentPrice() public view returns (uint) {
        return ((trees.length+1)*1)*10**18;
    }

    function _generateRandomDNA(uint _treeId) internal returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_treeId + Nonce)));
        Nonce++;
        return rand % Modulus;
    }

    function createNewTree() public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice());
        uint id = trees.length;
        uint DNA = _generateRandomDNA(id);
        trees.push(TreeStruct(DNA, 1, 0, false));
        _mint(msg.sender, id);
        emit NewTree(id);

    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

}