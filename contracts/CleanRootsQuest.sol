// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./AbstractTree.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CleanRootsQuest {

    event StartQuest(uint treeId);
    event FinishQuest(uint treeId);
    event CancelQuest(uint treeId);

    address ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
    
    //Get TreeAddress after TreeContract Deployment
    address TreeAddress = address(0);
    
    address Token = 0x70b3F9216A1600268146efC35944Efb376F4c4fc;
    address Treasury = 0xfd768E668A158C173e9549d1632902C2A4363178;
    Tree tree = Tree(TreeAddress);

    modifier onlyOwnerOf(uint _treeId) {
        require(tree.ownerOf(_treeId) == msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    //Payable Functions

    function startQuest(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) == 0);
        uint questDuration = 8*60*60;
        tree.updateQuestStatus(treeId, block.timestamp+questDuration);
        emit StartQuest(treeId);
    }

    function finishQuest(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        require(block.timestamp >= tree.questStatus(treeId));
        uint expReward = 10;
        uint tokenReward = 1*10**18;
        tree.gainExp(treeId, expReward);
        tree.updateQuestStatus(treeId, 0);
        IERC20(Token).transferFrom(Treasury, msg.sender, tokenReward);
        emit FinishQuest(treeId);

    }

    function cancelQuest(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        tree.updateQuestStatus(treeId, 0);
        emit CancelQuest(treeId);

    }

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }
}