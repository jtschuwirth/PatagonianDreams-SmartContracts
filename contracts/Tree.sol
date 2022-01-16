// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tree is ERC721Upgradeable {
    event NewTree(uint treeId);
    event GainExp(uint treeId, uint amount);
    event GainLevel(uint treeId);
    event BuildingLevelUp (uint treeId, uint buildingId);

    uint Nonce;
    uint Digits;
    uint Modulus;
    address ContractOwner;
    address Treasury;
    
    //Get Token Address after TokenContract deployment
    address Token;
    
    //QuestContract is updated after deployment
    address QuestContract;

    struct TreeStruct {
        uint treeDNA;
        uint level;
        uint exp;
        uint barracks;
        uint trainingGrounds;
        uint onQuestUntil;
    }

    TreeStruct[] public trees;

    //Modifiers

    modifier onlyOwnerOf(uint _treeId) {
        require(ownerOf(_treeId) == msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    modifier onlyQuestContract() {
        require(QuestContract == msg.sender);
        _;
    }

    function initialize() initializer public {
        Nonce = 1;
        Digits = 16;
        Modulus = 10 ** Digits;
        ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
        Treasury = 0xfd768E668A158C173e9549d1632902C2A4363178;
        Token = 0xCd571eD43B347a4Ab01BAe2d23F9535BBAFe955d;
        QuestContract = address(0);
        __ERC721_init("Patagonic Tree", "PTREE");
    }

    //View Functions

    function treeDNA(uint treeId) public view returns (uint) {
        return trees[treeId].treeDNA;
    }

    function treeLevel(uint treeId) public view returns (uint) {
        return trees[treeId].level;
    }

    function treeExp(uint treeId) public view returns (uint) {
        return trees[treeId].exp;
    }

    function treeBarracks(uint treeId) public view returns (uint) {
        return trees[treeId].barracks;
    }

    function treeTrainingGrounds(uint treeId) public view returns (uint) {
        return trees[treeId].trainingGrounds;
    }

    function questStatus(uint treeId) public view returns (uint) {
        return trees[treeId].onQuestUntil;
    }

    function currentPrice() public view returns (uint) {
        return ((trees.length+1)*1)*10**18;
    }

    //Payable Functions

    function upgradeBarracks(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].barracks);
        require(10 > trees[treeId].barracks);
        uint amount = trees[treeId].barracks*10**18;
        if (trees[treeId].barracks > 10 && trees[treeId].barracks < 21) {

        }
        IERC20(Token).transferFrom(msg.sender, Treasury, amount*70/100);
        IERC20(Token).transferFrom(msg.sender, ContractOwner, amount*30/100);
        trees[treeId].barracks++;
        emit BuildingLevelUp (treeId, 0);
    }

    function upgradeTrainingGrounds(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].trainingGrounds);
        require(10 > trees[treeId].trainingGrounds);
        uint amount = trees[treeId].trainingGrounds*10**18;
        if (trees[treeId].trainingGrounds > 10 && trees[treeId].trainingGrounds < 21) {

        }
        IERC20(Token).transferFrom(msg.sender, Treasury, amount*70/100);
        IERC20(Token).transferFrom(msg.sender, ContractOwner, amount*30/100);
        trees[treeId].trainingGrounds++;
        emit BuildingLevelUp (treeId, 1);
    }

    function updateQuestStatus(uint treeId, uint newValue) public payable onlyQuestContract() {
        trees[treeId].onQuestUntil = newValue;
    }

    function gainExp(uint treeId, uint amount) public payable onlyQuestContract() {
        //Cambiar a que solo lo pueda hacer el contrato de quests y no el usuario
        trees[treeId].exp = trees[treeId].exp + amount;
        emit GainExp(treeId, amount);
    }

    function gainLevel(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level < 100 );
        require(trees[treeId].exp >= trees[treeId].level*100);
        uint amount = trees[treeId].level*10**18;
        IERC20(Token).transferFrom(msg.sender, Treasury, amount*70/100);
        IERC20(Token).transferFrom(msg.sender, ContractOwner, amount*30/100);
        trees[treeId].exp = trees[treeId].exp-trees[treeId].level*100;
        trees[treeId].level++;
        emit GainLevel(treeId);
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
        trees.push(TreeStruct(DNA, 1, 0, 0, 0, 0));
        _mint(msg.sender, id);
        emit NewTree(id);

    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferQuestContract(address newQuestContract) public payable onlyOwner() {
        QuestContract = newQuestContract;
    }

}