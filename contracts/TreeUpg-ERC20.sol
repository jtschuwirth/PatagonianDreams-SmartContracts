// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "./AbstractTree.sol";
import "./AbstractTokenERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TreeUpg is Initializable, AccessControlUpgradeable {

    address TreeAddress;

    address BasicRune;
    address IntricateRune;
    address PowerfullRune;

    AbstractTree tree;
    AbstractToken BR;
    AbstractToken IR;
    AbstractToken PR;

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
            require(BR.balanceOf(msg.sender) >= BasicRuneAmount);
            BR.burn(msg.sender, BasicRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat > 2 && stat < 5) {
            uint BasicRuneAmount = (stat);
            uint IntricateRuneAmount = (stat);
            require(BR.balanceOf(msg.sender) >= BasicRuneAmount);
            require(IR.balanceOf(msg.sender) >= IntricateRuneAmount);
            BR.burn(msg.sender, BasicRuneAmount);
            IR.burn(msg.sender, IntricateRuneAmount);
            lvlUpStat(treeId, statId);
        } else if (stat > 3 && stat < 21) {
            uint BasicRuneAmount = (stat);
            uint IntricateRuneAmount = (stat);
            uint PowerfullRuneAmount = (stat);
            require(BR.balanceOf(msg.sender) >= BasicRuneAmount);
            require(IR.balanceOf(msg.sender) >= IntricateRuneAmount);
            require(PR.balanceOf(msg.sender) >= PowerfullRuneAmount);
            BR.burn(msg.sender, BasicRuneAmount);
            IR.burn(msg.sender, IntricateRuneAmount);
            PR.burn(msg.sender, PowerfullRuneAmount);
            lvlUpStat(treeId, statId);
        }
    }

    function transferTreeAddress(address newTree) public onlyRole(DEFAULT_ADMIN_ROLE) {
        TreeAddress = newTree;
        tree = AbstractTree(TreeAddress);
    }
}