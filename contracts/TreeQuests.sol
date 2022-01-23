// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;
import "./AbstractTree.sol";
import "./AbstractGameItems.sol";
import "./AbstractPudu.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TreeQuests is Initializable, AccessControlUpgradeable {

    event StartQuest(uint treeId, uint questId);
    event CompleteQuest(uint treeId, uint questId);
    event CancelQuest(uint treeId, uint questId);

    address TreasuryAddress;
    address TreeAddress;
    address TokenAddress;
    address GameItemsAddress;

    uint totalTreasuryBalance;

    AbstractTree tree;
    AbstractGameItems gameItems;
    AbstractPudu pudu;

    modifier onlyOwnerOf(uint _treeId) {
        require(tree.ownerOf(_treeId) == msg.sender);
        _;
    }

    function initialize() initializer public {
        TreasuryAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;

        totalTreasuryBalance = (1000000000*30*(10**18))/100;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
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

    function startQuest2(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) == 0);
        require(tree.currentAction(treeId) == 0);
        uint questDuration = 30*60 - tree.treeTrainingGrounds(treeId)*3*60;
        tree.updateAction(treeId, 2, block.timestamp+questDuration);
        emit StartQuest(treeId, 2);
    }

    function completeQuest2(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        require(tree.currentAction(treeId) == 2);
        require(block.timestamp >= tree.actionStatus(treeId));

        uint expReward = 10;
        uint treeMult = ceil(tree.treeBarracks(treeId),5)/5;
        uint tokenReward = (1*10**18)*treeMult/100;
        
        tree.updateAction(treeId, 0, 0);
        tree.gainExp(treeId, expReward);
        if (1000000000*10**18 >= IERC20(TokenAddress).totalSupply()+tokenReward ) {
            pudu.mint(msg.sender, tokenReward);
        } else {
            uint treasuryMult = treasuryMultiplicator();
            tokenReward = tokenReward*treasuryMult/100;
            IERC20(TokenAddress).transferFrom(TreasuryAddress, msg.sender, tokenReward);
        }
        emit CompleteQuest(treeId, 2);

    }

    function cancelQuest2(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        require(tree.currentAction(treeId) == 2);
        tree.updateAction(treeId, 0, 0);
        emit CancelQuest(treeId, 2);

    }

    //Quest1 Clean Roots

    function startQuest3(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) == 0);
        require(tree.currentAction(treeId) == 0);
        uint questDuration = 10*60 - tree.treeTrainingGrounds(treeId)*1*60;
        tree.updateAction(treeId, 3, block.timestamp+questDuration);
        emit StartQuest(treeId, 3);
    }

    function completeQuest3(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        require(tree.currentAction(treeId) == 3);
        require(block.timestamp >= tree.actionStatus(treeId));

        uint expReward = 100;
        uint rand = uint(keccak256(abi.encodePacked(vrf())));
        uint chance = rand%10;
        tree.updateAction(treeId, 0, 0);
        tree.gainExp(treeId, expReward);
        if (chance == 0) {
            gameItems.mint(msg.sender, 0, 1);
        }
        emit CompleteQuest(treeId, 3);

    }

    function cancelQuest3(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        require(tree.currentAction(treeId) == 3);
        tree.updateAction(treeId, 0, 0);
        emit CancelQuest(treeId, 3);

    }

    //Transfer functions

    function transferTreasuryAddress(address newTreasury) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        TreasuryAddress = newTreasury;
    }

    function transferTokenAddress(address newToken) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        TokenAddress = newToken;
        pudu = AbstractPudu(TokenAddress);
    }

    function transferGameItemsAddress(address newGameItems) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        GameItemsAddress = newGameItems;
        gameItems = AbstractGameItems(GameItemsAddress);
    }

    function transferTreeAddress(address newTree) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        TreeAddress = newTree;
        tree = AbstractTree(TreeAddress);
    }

}