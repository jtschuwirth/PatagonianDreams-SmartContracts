// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "./AbstractTree.sol";
import "./AbstractGameItems.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TreeUpg is Initializable, AccessControlUpgradeable {

    address TreeAddress;
    address GameItemsAddress;

    AbstractTree tree;
    AbstractGameItems gameItems;

    modifier onlyOwnerOf(uint _treeId) {
        require(tree.ownerOf(_treeId) == msg.sender);
        _;
    }

    function initialize() initializer public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function upgradeLevel(uint treeId) public payable onlyOwnerOf(treeId) {
        require(tree.treeLevel(treeId) < 100 );
        require(tree.treeExp(treeId) >= tree.treeLevel(treeId)*100);
        require(tree.currentAction(treeId) == 0);
        tree.gainLevel(treeId, msg.sender);
    }

    function lvlUpStat(uint treeId, uint statId) internal {
        if (statId == 0) {
            tree.levelUpRoots(treeId, msg.sender);
        } else if (statId == 1) {
            tree.levelUpBranches(treeId, msg.sender);
        }
    }

    function upgradeStat(uint treeId, uint statId) public payable onlyOwnerOf(treeId) {
        uint stat;
        if (statId == 0) {
            stat = tree.treeRoots(treeId);
        } else if (statId == 1) {
            stat = tree.treeBranches(treeId);
        }

        require(tree.treeLevel(treeId) > stat);
        require(21 > stat);
        require(tree.currentAction(treeId) == 0);
        
        if (stat > 0 && stat < 2) {
            lvlUpStat(treeId, statId);
        } else if (stat > 1 && stat < 3) {
            uint BasicRuneAmount = (stat);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat > 2 && stat < 5) {
            uint BasicRuneAmount = (stat);
            uint IntricateRuneAmount = (stat);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 1, IntricateRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat > 3 && stat < 21) {
            uint BasicRuneAmount = (stat);
            uint IntricateRuneAmount = (stat);
            uint PowerfullRuneAmount = (stat);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            require(gameItems.balanceOf(msg.sender, 2) >= PowerfullRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 1, IntricateRuneAmount);
            gameItems.burn(msg.sender, 2, PowerfullRuneAmount);
            lvlUpStat(treeId, statId);
        }
    }

    function transferGameItemsAddress(address newGameItems) public onlyRole(DEFAULT_ADMIN_ROLE) {
        GameItemsAddress = newGameItems;
        gameItems = AbstractGameItems(GameItemsAddress);
    }

    function transferTreeAddress(address newTree) public onlyRole(DEFAULT_ADMIN_ROLE) {
        TreeAddress = newTree;
        tree = AbstractTree(TreeAddress);
    }
}