// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Tree is ERC721Upgradeable, AccessControlUpgradeable {

    bytes32 public constant QUEST_ROLE = keccak256("QUEST_ROLE");
    bytes32 public constant UPG_ROLE = keccak256("UPG_ROLE");

    event NewTree(uint256 treeId);
    event GainExp(uint256 treeId, uint256 amount);
    event GainLevel(uint256 treeId);
    event StatLevelUp (uint256 treeId, uint256 statId);

    uint256 Digits;
    uint256 Modulus;

    address payable DevelopmentAddress;
    address payable TreasuryAddress;
    address TokenAddress;

    struct TreeStruct {
        uint256 treeDNA;
        uint256 level;
        uint256 exp;
        uint256 roots;
        uint256 branches;
        uint256 action;
        uint256 onActionUntil;
    }

    mapping(uint256 => TreeStruct) trees;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private treeCounter;

    constructor() initializer {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function initialize() initializer public {
        Digits = 16;
        Modulus = 10 ** Digits;

        DevelopmentAddress = payable(0x7C50D01C7Ba0EDE836bDA6daC88A952f325756e3);
        TreasuryAddress = payable(0xa691623968855b91A066661b0552a7D3764c9a64);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ERC721_init("Patagonic Tree", "pTree");
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

    function getTree(uint256 treeId) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        TreeStruct memory tree = trees[treeId];
        return (tree.treeDNA, tree.level, tree.exp, tree.roots, tree.branches, tree.action, tree.onActionUntil);
    }

    function getBranches(uint256 treeId) external view returns (uint256) {
        return trees[treeId].branches;
    }

    function getRoots(uint256 treeId) external view returns (uint256) {
        return trees[treeId].roots;
    }


    function getLevel(uint256 treeId) external view returns (uint256) {
        return trees[treeId].level;
    }

    function getExp(uint256 treeId) external view returns (uint256) {
        return trees[treeId].exp;
    }


    function getAction(uint256 treeId) external view returns (uint256) {
        return trees[treeId].action;
    }

    function getActionUntil(uint256 treeId) external view returns (uint256) {
        return trees[treeId].onActionUntil;
    }

    function currentPrice() public view returns (uint256) {
        uint256 basePrice = 1;
        uint256 scalingPrice = 1;
        uint256 scalingAmount = 5;
        uint256 price = (basePrice*10**18)+(treeCounter.current()/scalingAmount)*scalingPrice*10**18;
        return price;
    }

    function _generateRandomDNA() internal view returns (uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked(vrf())));
        return rand % Modulus;
    }

    function getTreeQuantities() external view returns (uint256) {
        return treeCounter.current();
    }

    //External Functions

    function gainLevel(uint256 treeId, address user) external onlyRole(UPG_ROLE) {
        uint256 amount = trees[treeId].level*10**18;
        require(IERC20Upgradeable(TokenAddress).balanceOf(user)>= amount);
        IERC20Upgradeable(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20Upgradeable(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].exp = trees[treeId].exp-trees[treeId].level*100;
        trees[treeId].level++;
        emit GainLevel(treeId);
    }

    function gainExp(uint256 treeId, uint256 amount) external onlyRole(QUEST_ROLE) {
        trees[treeId].exp = trees[treeId].exp + amount;
        emit GainExp(treeId, amount);
    }

    function levelUpBranches(uint256 treeId, address user) external onlyRole(UPG_ROLE) {
        uint256 amount = trees[treeId].branches*10**18;
        require(IERC20Upgradeable(TokenAddress).balanceOf(user)>= amount);
        IERC20Upgradeable(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20Upgradeable(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].branches++;
        emit StatLevelUp (treeId, 0);
    }
    function levelUpRoots(uint256 treeId, address user) external onlyRole(UPG_ROLE) {
        uint256 amount = trees[treeId].roots*10**18;
        require(IERC20Upgradeable(TokenAddress).balanceOf(user)>= amount);
        IERC20Upgradeable(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20Upgradeable(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        trees[treeId].roots++;
        emit StatLevelUp (treeId, 1);
    }

    function updateAction(uint256 treeId, uint256 action, uint256 time) external onlyRole(QUEST_ROLE) {
        trees[treeId].onActionUntil = time;
        trees[treeId].action = action;
    }

    //Payable Functions

    function createNewTree() external payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value == currentPrice());
        uint256 DNA = _generateRandomDNA();
        uint256 current = treeCounter.current();
        treeCounter.increment();
        trees[current] = TreeStruct(DNA, 1, 0, 1, 1, 0, 0);
        _mint(msg.sender, current);
        retrieveFunds(current);
        emit NewTree(current);

    }

    //Retrive Funds

    function retrieveFunds(uint256 treeId) internal {
        if (treeId < 2000) {
            TreasuryAddress.transfer(payable(address(this)).balance/2);
            DevelopmentAddress.transfer(payable(address(this)).balance/2);
        } else {
            TreasuryAddress.transfer(payable(address(this)).balance);
        }
    }

    //Transfer Functions

    function transferDevelopmentAddress(address payable newDevelopment) external onlyRole(DEFAULT_ADMIN_ROLE) {
        DevelopmentAddress = newDevelopment;
    }

    function transferTreasuryAddress(address payable newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TreasuryAddress = newTreasury;
    }

    function transferTokenAddress(address newToken) external onlyRole(DEFAULT_ADMIN_ROLE) {
        TokenAddress = newToken;
    }

}