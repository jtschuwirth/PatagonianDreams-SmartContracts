// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "./Abstracts/AbstractTree.sol";
import "./Abstracts/AbstractGameItems.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

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
        require(tree.getLevel(treeId) < 100 );
        require(tree.getExp(treeId) >= tree.getLevel(treeId)*100);
        require(tree.getAction(treeId) == 0);
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
            stat = tree.getRoots(treeId);
        } else if (statId == 1) {
            stat = tree.getBranches(treeId);
        }

        require(tree.getLevel(treeId) > stat);
        require(21 > stat);
        require(tree.getAction(treeId) == 0);
        
        if (stat < 6) {
            lvlUpStat(treeId, statId);
        } else if (stat < 11) {
            uint BasicRuneAmount = stat-5;
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat < 16) {
            uint IntricateRuneAmount = stat-10;
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            gameItems.burn(msg.sender, 1, IntricateRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat < 21) {
            uint PowerfullRuneAmount = stat-15;
            require(gameItems.balanceOf(msg.sender, 2) >= PowerfullRuneAmount);
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