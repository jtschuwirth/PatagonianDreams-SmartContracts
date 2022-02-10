// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;
import "./AbstractTree.sol";
import "./AbstractGameItems.sol";
import "./AbstractPudu.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TreeQuests is Initializable, AccessControlUpgradeable {

    event StartQuest(uint treeId, uint questId);
    event CompleteQuest(uint treeId, uint questId);
    event CancelQuest(uint treeId);

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

    function questLength(uint treeId, uint questId) public view returns (uint){
        uint length;
        if (questId == 1) {
            length = 1*60 - tree.treeBranches(treeId)*1;
        } else if (questId == 2) {
            length = 1*60 - tree.treeBranches(treeId)*1;
        }
        return length;
    }

    function startQuest(uint treeId, uint questId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) == 0);
        require(tree.currentAction(treeId) == 0);
        if (questId == 1) {
            startQuest1(treeId);
        } else if (questId == 2) {
            startQuest2(treeId);
        }
    }

    function completeQuest(uint treeId, uint questId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        require(block.timestamp >= tree.actionStatus(treeId));
        if (questId == 1) {
            completeQuest1(treeId);
        } else if (questId == 2) {
            completeQuest2(treeId);
        }
    }

    function cancelQuest(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.actionStatus(treeId) != 0);
        tree.updateAction(treeId, 0, 0);
        emit CancelQuest(treeId);
    }

    function startQuest1(uint treeId) internal {
        uint length = questLength(treeId, 1);
        tree.updateAction(treeId, 1, block.timestamp+length);
        emit StartQuest(treeId, 1);
    }

    function completeQuest1(uint treeId) internal {
        require(tree.currentAction(treeId) == 1);

        uint expReward = 100;
        uint tokenReward = (10**18)+(10**18)*tree.treeRoots(treeId)*10/100;

        tree.updateAction(treeId, 0, 0);
        tree.gainExp(treeId, expReward);
        if (1000000000*10**18 >= pudu.totalSupply()+tokenReward) {
            pudu.mint(msg.sender, tokenReward);
        }
        emit CompleteQuest(treeId, 1);

    }

    function startQuest2(uint treeId) internal {
        uint length = questLength(treeId, 2);
        tree.updateAction(treeId, 2, block.timestamp+length);
        emit StartQuest(treeId, 2);
    }

    function completeQuest2(uint treeId) internal {
        require(tree.currentAction(treeId) == 2);

        uint expReward = 100;
        tree.updateAction(treeId, 0, 0);
        tree.gainExp(treeId, expReward);
        uint rand1 = uint(keccak256(abi.encodePacked(vrf())));
        uint chance1 = rand1%100;
        if (chance1 < 50) {
            gameItems.mint(msg.sender, 0, 5);
        }
        uint rand2 = uint(keccak256(abi.encodePacked(vrf())));
        uint chance2 = rand2%100;
        if (chance2 < 25) {
            gameItems.mint(msg.sender, 1, 5);
        }
        uint rand3 = uint(keccak256(abi.encodePacked(vrf())));
        uint chance3 = rand3%100;
        if (chance3 < 10) {
            gameItems.mint(msg.sender, 2, 5);
        }
        emit CompleteQuest(treeId, 2);

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