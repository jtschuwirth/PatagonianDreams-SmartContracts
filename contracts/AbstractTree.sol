// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract AbstractTree is ERC721 {
    //View Functions

    function treeDNA(uint treeId) public virtual returns (uint);

    function treeLevel(uint treeId) public virtual returns (uint);

    function treeExp(uint treeId) public virtual returns (uint);

    function treeRoots(uint treeId) public virtual returns (uint);

    function treeBranches(uint treeId) public virtual returns (uint);

    function actionStatus(uint treeId) public virtual returns (uint);

    function currentAction(uint treeId) public virtual returns (uint);

    function currentPrice() public virtual returns (uint);

    //Payable Functions

    function upgradeRoots(uint treeId) public virtual;

    function upgradeBranches(uint treeId) public virtual;

    function updateAction(uint treeId, uint action, uint value) public virtual;

    function gainExp(uint treeId, uint amount) public virtual;

    function gainLevel(uint treeId) public virtual;

    function createNewTree() public virtual;
}