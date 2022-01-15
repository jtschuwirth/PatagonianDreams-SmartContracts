// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./AbstractTree.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract TreeQuests is Initializable {

    event StartQuest(uint treeId, uint questId);
    event CompleteQuest(uint treeId, uint questId);
    event CancelQuest(uint treeId, uint questId);

    address ContractOwner;
    address Treasury;
    
    //Get TreeAddress after TreeContract Deployment
    address TreeAddress;
    
    //Get TokenAddress after TokenContract Deployment
    address Token;
    uint totalTreasuryBalance;

    Tree tree;

    modifier onlyOwnerOf(uint _treeId) {
        require(tree.ownerOf(_treeId) == msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(ContractOwner == msg.sender);
        _;
    }

    function initialize() initializer public {
        ContractOwner = 0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D;
        Treasury = 0xfd768E668A158C173e9549d1632902C2A4363178;
        TreeAddress = 0x56Ab64E87641864C0849d4A4Ef4D1Fd7245b2e27;
        Token = 0xCd571eD43B347a4Ab01BAe2d23F9535BBAFe955d;
        totalTreasuryBalance = 4000000;
        tree = Tree(TreeAddress);
    }
    
    // Util functions

    function ceil(uint _a, uint _m) internal pure returns (uint ) {
        return ((_a + _m - 1) / _m) * _m;
    }
    function treasuryMultiplicator() public view returns (uint) {
        uint currentTreasuryBalance = IERC20(Token).balanceOf(Treasury);
        if (currentTreasuryBalance >= totalTreasuryBalance*5/100) {
            return 100;
        } else if (currentTreasuryBalance >= totalTreasuryBalance*4/100) {
            return 80;
        } else if (currentTreasuryBalance >= totalTreasuryBalance*3/100) {
            return 60;
        } else if (currentTreasuryBalance >= totalTreasuryBalance*2/100) {
            return 40;
        } else if (currentTreasuryBalance >= totalTreasuryBalance*1/100) {
            return 20;
        } else if (currentTreasuryBalance >= totalTreasuryBalance*1/1000) {
            return 5;
        } else {
            return 0;
        }
    }

    //Payable Functions

    //Quest0 Foraging

    function startQuest0(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) == 0);
        uint questDuration = 30*60 - tree.treeTrainingGrounds(treeId)*3*60;
        tree.updateQuestStatus(treeId, block.timestamp+questDuration);
        emit StartQuest(treeId, 0);
    }

    function completeQuest0(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        require(block.timestamp >= tree.questStatus(treeId));

        uint expReward = 10;
        tree.gainExp(treeId, expReward);

        uint treeMult = ceil(tree.treeBarracks(treeId),5)/5;
        uint treasuryMult = treasuryMultiplicator();
        uint tokenReward = (1*10**18)*treasuryMult*treeMult/100;
        tree.updateQuestStatus(treeId, 0);
        IERC20(Token).transferFrom(Treasury, msg.sender, tokenReward);
        emit CompleteQuest(treeId, 0);

    }

    function cancelQuest0(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        tree.updateQuestStatus(treeId, 0);
        emit CancelQuest(treeId, 0);

    }

    //Quest1 Clean Roots

    function startQuest1(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) == 0);
        uint questDuration = 10*60 - tree.treeTrainingGrounds(treeId)*1*60;
        tree.updateQuestStatus(treeId, block.timestamp+questDuration);
        emit StartQuest(treeId, 1);
    }

    function completeQuest1(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        require(block.timestamp >= tree.questStatus(treeId));

        uint expReward = 100;
        tree.gainExp(treeId, expReward);
        emit CompleteQuest(treeId, 1);

    }

    function cancelQuest1(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.questStatus(treeId) != 0);
        tree.updateQuestStatus(treeId, 0);
        emit CancelQuest(treeId, 1);

    }

    //Transfer functions

    function transferOwnership(address newOwner) public payable onlyOwner() {
        ContractOwner = newOwner;
    }

    function transferTreasury(address newTreasury) public payable onlyOwner() {
        Treasury = newTreasury;
    }
}