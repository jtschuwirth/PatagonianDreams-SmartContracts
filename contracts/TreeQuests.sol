// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;
import "./AbstractTree.sol";
import "./AbstractGameItems.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TreeQuests is Initializable {

    event StartQuest(uint treeId, uint questId);
    event CompleteQuest(uint treeId, uint questId);
    event CancelQuest(uint treeId, uint questId);

    address ContractOwner;
    address TreasuryAddress;
    
    //Get TreeAddress after TreeContract Deployment
    address TreeAddress;
    
    //Get TokenAddress after TokenContract Deployment
    address TokenAddress;
    address GameItemsAddress;
    uint totalTreasuryBalance;

    AbstractTree tree;
    AbstractGameItems gameItems;

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
        TreasuryAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;
        TreeAddress = 0x066a907192376088248935AbaD90DaCD06E87F64;
        TokenAddress = 0x54301761569145d50da03d8CfdfA19913f20Ed9b;
        GameItemsAddress = 0x25ef7FdEA435D7Aaed551E8256792E46d0293d34;
        totalTreasuryBalance = 4000000;
        tree = AbstractTree(TreeAddress);
        gameItems = AbstractGameItems(GameItemsAddress);
    }
    
    // Util functions

    function ceil(uint _a, uint _m) internal pure returns (uint ) {
        return ((_a + _m - 1) / _m) * _m;
    }

    function treasuryMultiplicator() public view returns (uint) {
        uint currentTreasuryBalance = IERC20(TokenAddress).balanceOf(TreasuryAddress);
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
        uint treeMult = ceil(tree.treeBarracks(treeId),5)/5;
        uint treasuryMult = treasuryMultiplicator();
        uint tokenReward = (1*10**18)*treasuryMult*treeMult/100;
        
        tree.updateQuestStatus(treeId, 0);
        tree.gainExp(treeId, expReward);
        IERC20(TokenAddress).transferFrom(TreasuryAddress, msg.sender, tokenReward);
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
        uint rand = uint(keccak256(abi.encodePacked(vrf())));
        uint chance = rand%10;
        tree.updateQuestStatus(treeId, 0);
        tree.gainExp(treeId, expReward);
        if (chance == 0) {
            gameItems.mint(msg.sender, 0, 1);
        }
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
        TreasuryAddress = newTreasury;
    }

    function transferTree(address newTree) public payable onlyOwner() {
        TreeAddress = newTree;
        tree = AbstractTree(TreeAddress);
    }

    function transferGameItemsContract(address newGameItems) public payable onlyOwner() {
        GameItemsAddress = newGameItems;
        gameItems = AbstractGameItems(GameItemsAddress);
    }

    function transferToken(address newToken) public payable onlyOwner() {
        TokenAddress = newToken;
    }
}