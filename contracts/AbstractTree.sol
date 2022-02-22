// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract AbstractTree is ERC721 {
    //View Functions

    function getTree(uint256 treeId) external view virtual returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    function getBranches(uint256 treeId) external view virtual returns (uint256);

    function getRoots(uint256 treeId) external view virtual returns (uint256);

    function getLevel(uint256 treeId) external view virtual returns (uint256);

    function getExp(uint256 treeId) external view virtual returns (uint256);

    function getAction(uint256 treeId) external view virtual returns (uint256);

    function getActionUntil(uint256 treeId) external view virtual returns (uint256);

    function currentPrice() public view virtual returns (uint256);

    function getTreeQuantities() external view virtual returns (uint256);

    //Payable Functions

    function gainLevel(uint256 treeId, address user) external virtual;

    function gainExp(uint256 treeId, uint256 amount) external virtual;

    function levelUpBranches(uint256  treeId, address user) external virtual;

    function levelUpRoots(uint256  treeId, address user) external virtual;

    function updateAction(uint256 treeId, uint256 action, uint256 time) external virtual;

    function createNewTree() external payable virtual;

    function retrieveFunds(uint256 treeId) internal virtual;
}