// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./AbstractTree.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CleanRootsQuest {

    event StartQuest(uint treeId);
    event CompleteQuest(uint treeId);
    event CancelQuest(uint treeId);

    address ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
    address Treasury = 0xfd768E668A158C173e9549d1632902C2A4363178;
    
    //Get TreeAddress after TreeContract Deployment
    address TreeAddress = 0x190460adF29CD8FA28B537a8E403cb36C0fc84cC;
    
    //Get TokenAddress after TokenContract Deployment
    address Token = 0xCd571eD43B347a4Ab01BAe2d23F9535BBAFe955d;

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

    function completeQuest(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        require(block.timestamp >= tree.questStatus(treeId));
        uint expReward = 10;
        uint tokenReward = 1*10**18;
        tree.gainExp(treeId, expReward);
        tree.updateQuestStatus(treeId, 0);
        IERC20(Token).transferFrom(Treasury, msg.sender, tokenReward);
        emit CompleteQuest(treeId);

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