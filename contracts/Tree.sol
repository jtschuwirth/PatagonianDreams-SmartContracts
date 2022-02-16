// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Tree is ERC721Upgradeable, AccessControlUpgradeable {

    bytes32 public constant QUEST_ROLE = keccak256("QUEST_ROLE");
    bytes32 public constant UPG_ROLE = keccak256("UPG_ROLE");

    event NewTree(uint treeId);
    event GainExp(uint treeId, uint amount);
    event GainLevel(uint treeId);
    event StatLevelUp (uint treeId, uint statId);

    uint Digits;
    uint Modulus;

    address payable DevelopmentAddress;
    address payable TreasuryAddress;
    address TokenAddress;

    struct TreeStruct {
        uint treeDNA;
        uint level;
        uint exp;
        uint roots;
        uint branches;
        uint action;
        uint onActionUntil;
    }

    TreeStruct[] public trees;

    //Modifiers

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function initialize() initializer public {
        Digits = 16;
        Modulus = 10 ** Digits;

        DevelopmentAddress = payable(0x7C50D01C7Ba0EDE836bDA6daC88A952f325756e3);
        TreasuryAddress = payable(0xa691623968855b91A066661b0552a7D3764c9a64);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ERC721_init("Patagonic Tree", "PTREE");
    }

    //Util Functions

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

    //View Functions

    function treeDNA(uint treeId) public view returns (uint) {
        return trees[treeId].treeDNA;
    }

    function treeLevel(uint treeId) public view returns (uint) {
        return trees[treeId].level;
    }

    function treeExp(uint treeId) public view returns (uint) {
        return trees[treeId].exp;
    }

    function treeRoots(uint treeId) public view returns (uint) {
        return trees[treeId].roots;
    }

    function treeBranches(uint treeId) public view returns (uint) {
        return trees[treeId].branches;
    }

    function actionStatus(uint treeId) public view returns (uint) {
        return trees[treeId].onActionUntil;
    }

    function currentAction(uint treeId) public view returns (uint) {
        return trees[treeId].action;
    }

    function currentPrice() public view returns (uint) {
        uint basePrice = 1;
        uint scalingPrice = 1;
        uint scalingAmount = 5;
        uint price = (basePrice*10**18)+(trees.length/scalingAmount)*scalingPrice*10**18;
        return price;
    }

    function _generateRandomDNA() internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(vrf())));
        return rand % Modulus;
    }

    function treesQuantity() public view returns (uint) {
        uint quantity = trees.length;
        return quantity;
    }

    //Public Functions

    function gainLevel(uint treeId, address user) public onlyRole(UPG_ROLE) {
        uint amount = trees[treeId].level*10**18;
        require(IERC20(TokenAddress).balanceOf(user)>= amount);
        IERC20(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].exp = trees[treeId].exp-trees[treeId].level*100;
        trees[treeId].level++;
        emit GainLevel(treeId);
    }

    function gainExp(uint treeId, uint amount) public onlyRole(QUEST_ROLE) {
        trees[treeId].exp = trees[treeId].exp + amount;
        emit GainExp(treeId, amount);
    }

    function levelUpBranches(uint treeId, address user) public onlyRole(UPG_ROLE) {
        uint amount = trees[treeId].branches*10**18;
        require(IERC20(TokenAddress).balanceOf(user)>= amount);
        IERC20(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].branches++;
        emit StatLevelUp (treeId, 0);
    }
    function levelUpRoots(uint treeId, address user) public onlyRole(UPG_ROLE) {
        uint amount = trees[treeId].roots*10**18;
        require(IERC20(TokenAddress).balanceOf(user)>= amount);
        IERC20(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].roots++;
        emit StatLevelUp (treeId, 1);
    }

    function updateAction(uint treeId, uint action, uint time) public onlyRole(QUEST_ROLE) {
        trees[treeId].onActionUntil = time;
        trees[treeId].action = action;
    }

    //Payable Functions

    function createNewTree() public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value == currentPrice());
        uint id = trees.length;
        uint DNA = _generateRandomDNA();
        trees.push(TreeStruct(DNA, 1, 0, 1, 1, 0, 0));
        _mint(msg.sender, id);
        retrieveFunds(id);
        emit NewTree(id);

    }

    //Retrive Funds

    function retrieveFunds(uint treeId) internal {
        if (treeId < 2000) {
            TreasuryAddress.transfer(payable(address(this)).balance/2);
            DevelopmentAddress.transfer(payable(address(this)).balance/2);
        } else {
            TreasuryAddress.transfer(payable(address(this)).balance);
        }
    }

    //Transfer Functions

    function transferDevelopmentAddress(address payable newDevelopment) public onlyRole(DEFAULT_ADMIN_ROLE) {
        DevelopmentAddress = newDevelopment;
    }

    function transferTreasuryAddress(address payable newTreasury) public onlyRole(DEFAULT_ADMIN_ROLE) {
        TreasuryAddress = newTreasury;
    }

    function transferTokenAddress(address newToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        TokenAddress = newToken;
    }

}