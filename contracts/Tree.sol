// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract TreeV3 is ERC721Upgradeable {
    event NewTree(uint treeId);
    event GainExp(uint treeId, uint amount);
    event GainLevel(uint treeId);
    event BuildingLevelUp (uint treeId, uint buildingId);

    uint Digits;
    uint Modulus;

    address ContractOwner;
    address TreasuryAddress;
    address TokenAddress;
    address GameItemsAddress;
    address QuestAddress;

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
        require(QuestAddress == msg.sender);
        _;
    }

    function initialize() initializer public {
        Digits = 16;
        Modulus = 10 ** Digits;

        ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
        TreasuryAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;

        __ERC721_init("Patagonic Tree", "PTREE");
    }

    //Util Functions

    function vrf() public view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
                invalid()
            }
            result := mload(memPtr)
        }
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

    function _generateRandomDNA() internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(vrf())));
        return rand % Modulus;
    }

    //Payable Functions

    function upgradeBarracks(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].barracks);
        require(21 > trees[treeId].barracks);
        require(trees[treeId].onQuestUntil == 0);
        uint amount = trees[treeId].barracks*10**18;
        if (trees[treeId].barracks > 10 && trees[treeId].barracks < 21) {
            uint BasicRuneAmount = (trees[treeId].barracks-10);
            IERC1155(GameItemsAddress).safeTransferFrom(msg.sender, address(0), 0, BasicRuneAmount, "");
        }
        trees[treeId].barracks++;
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*90/100);
        IERC20(TokenAddress).transferFrom(msg.sender, address(0), amount*6/100);
        IERC20(TokenAddress).transferFrom(msg.sender, ContractOwner, amount*4/100);
        emit BuildingLevelUp (treeId, 0);
    }

    function upgradeTrainingGrounds(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].trainingGrounds);
        require(21 > trees[treeId].trainingGrounds);
        require(trees[treeId].onQuestUntil == 0);
        uint amount = trees[treeId].trainingGrounds*10**18;
        if (trees[treeId].trainingGrounds > 10 && trees[treeId].trainingGrounds < 21) {
            uint BasicRuneAmount = (trees[treeId].trainingGrounds-10);
            IERC1155(GameItemsAddress).safeTransferFrom(msg.sender, address(0), 0, BasicRuneAmount, "");
        }
        trees[treeId].trainingGrounds++;
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*90/100);
        IERC20(TokenAddress).transferFrom(msg.sender, address(0), amount*6/100);
        IERC20(TokenAddress).transferFrom(msg.sender, ContractOwner, amount*4/100);
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
        require(trees[treeId].onQuestUntil == 0);
        uint amount = trees[treeId].level*10**18;
        trees[treeId].exp = trees[treeId].exp-trees[treeId].level*100;
        trees[treeId].level++;
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*90/100);
        IERC20(TokenAddress).transferFrom(msg.sender, address(0), amount*6/100);
        IERC20(TokenAddress).transferFrom(msg.sender, ContractOwner, amount*4/100);
        emit GainLevel(treeId);
    }

    function createNewTree() public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice());
        uint id = trees.length;
        uint DNA = _generateRandomDNA();
        trees.push(TreeStruct(DNA, 1, 0, 0, 0, 0));
        _mint(msg.sender, id);
        emit NewTree(id);

    }

    //Transfer Functions

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferTreasuryAddress(address newTreasury) public payable onlyOwner() {
        TreasuryAddress = newTreasury;
    }

    function transferTokenAddress(address newToken) public payable onlyOwner() {
        TokenAddress = newToken;
    }

    function transferGameItemsAddress(address newGameItems) public payable onlyOwner() {
        GameItemsAddress = newGameItems;
    }

    function transferQuestAddress(address newQuest) public payable onlyOwner() {
        QuestAddress = newQuest;
    }
}