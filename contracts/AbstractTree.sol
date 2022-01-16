// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract AbstractTree is ERC721 {
    //View Functions

    function treeDNA(uint treeId) public virtual returns (uint);

    function treeLevel(uint treeId) public virtual returns (uint);

    function treeExp(uint treeId) public virtual returns (uint);

    function treeBarracks(uint treeId) public virtual returns (uint);

    function treeTrainingGrounds(uint treeId) public virtual returns (uint);

    function questStatus(uint treeId) public virtual returns (uint);

    function currentPrice() public virtual returns (uint);

    //Payable Functions

    function upgradeBarracks(uint treeId) public virtual;

    function upgradeTrainingGrounds(uint treeId) public virtual;

    function updateQuestStatus(uint treeId, uint newValue) public virtual;

    function gainExp(uint treeId, uint amount) public virtual;

    function gainLevel(uint treeId) public virtual;

    function createNewTree() public virtual;

    function transferOwnership(address newOwner) public virtual;

    function transferQuestContract(address newQuestContract) public virtual;
}