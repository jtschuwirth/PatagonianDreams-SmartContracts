// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "./AbstractGameItems.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract Tree is ERC721Upgradeable, AccessControlUpgradeable {

    bytes32 public constant QUEST_ROLE = keccak256("QUEST_ROLE");

    event NewTree(uint treeId);
    event GainExp(uint treeId, uint amount);
    event GainLevel(uint treeId);
    event StatLevelUp (uint treeId, string stat);

    uint Digits;
    uint Modulus;

    address DevelopmentAddress;
    address TreasuryAddress;
    address TokenAddress;
    address GameItemsAddress;

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
    AbstractGameItems gameItems;

    //Modifiers

    modifier onlyOwnerOf(uint _treeId) {
        require(ownerOf(_treeId) == msg.sender);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function initialize() initializer public {
        Digits = 16;
        Modulus = 10 ** Digits;

        DevelopmentAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;
        TreasuryAddress = 0xfd768E668A158C173e9549d1632902C2A4363178;
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
        return (trees.length+1)*10**18;
    }

    function _generateRandomDNA() internal view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(vrf())));
        return rand % Modulus;
    }

    function treesQuantity() public view returns (uint) {
        uint quantity = trees.length;
        return quantity;
    }

    //Internal Functions

    function levelUpBranches(uint treeId, uint amount) internal {
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(msg.sender, DevelopmentAddress, amount*4/100);
        trees[treeId].branches++;
    }
    function levelUpRoots(uint treeId, uint amount) internal {
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(msg.sender, DevelopmentAddress, amount*4/100);
        trees[treeId].roots++;
    }

    //Payable Functions

    function upgradeRoots(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].roots);
        require(21 > trees[treeId].roots);
        require(trees[treeId].action == 0);
        uint amount = trees[treeId].roots*10**18;
        require(IERC20(TokenAddress).balanceOf(msg.sender)>= amount);
        
        if (trees[treeId].roots > 0 && trees[treeId].roots < 2) {
            levelUpRoots(treeId, amount);
        } else if (trees[treeId].roots > 1 && trees[treeId].roots < 3) {
            uint BasicRuneAmount = (trees[treeId].roots);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            levelUpRoots(treeId, amount);
        } else if (trees[treeId].roots > 2 && trees[treeId].roots < 5) {
            uint BasicRuneAmount = (trees[treeId].roots);
            uint IntricateRuneAmount = (trees[treeId].roots);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 1, IntricateRuneAmount);
            levelUpRoots(treeId, amount);
        } else if (trees[treeId].roots > 3 && trees[treeId].roots < 21) {
            uint BasicRuneAmount = (trees[treeId].roots);
            uint IntricateRuneAmount = (trees[treeId].roots);
            uint PowerfullRuneAmount = (trees[treeId].roots);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            require(gameItems.balanceOf(msg.sender, 2) >= PowerfullRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 0, IntricateRuneAmount);
            gameItems.burn(msg.sender, 0, PowerfullRuneAmount);
            levelUpRoots(treeId, amount);
        }
        emit StatLevelUp (treeId, "roots");
    }

    function upgradeBranches(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level > trees[treeId].branches);
        require(21 > trees[treeId].branches);
        require(trees[treeId].action == 0);
        uint amount = trees[treeId].branches*10**18;
        require(IERC20(TokenAddress).balanceOf(msg.sender)>= amount);

        if (trees[treeId].branches > 0 && trees[treeId].branches < 2) {
            levelUpBranches(treeId, amount);
        } else if (trees[treeId].branches > 1 && trees[treeId].branches < 3) {
            uint BasicRuneAmount = (trees[treeId].branches);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            levelUpBranches(treeId, amount);
        } else if (trees[treeId].branches > 2 && trees[treeId].branches < 4) {
            uint BasicRuneAmount = (trees[treeId].branches);
            uint IntricateRuneAmount = (trees[treeId].branches);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 1, IntricateRuneAmount);
            levelUpBranches(treeId, amount);
        } else if (trees[treeId].branches > 3 && trees[treeId].branches < 21) {
            uint BasicRuneAmount = (trees[treeId].branches);
            uint IntricateRuneAmount = (trees[treeId].branches);
            uint PowerfullRuneAmount = (trees[treeId].branches);
            require(gameItems.balanceOf(msg.sender, 0) >= BasicRuneAmount);
            require(gameItems.balanceOf(msg.sender, 1) >= IntricateRuneAmount);
            require(gameItems.balanceOf(msg.sender, 2) >= PowerfullRuneAmount);
            gameItems.burn(msg.sender, 0, BasicRuneAmount);
            gameItems.burn(msg.sender, 0, IntricateRuneAmount);
            gameItems.burn(msg.sender, 0, PowerfullRuneAmount);
            levelUpBranches(treeId, amount);
        }
        emit StatLevelUp (treeId, "branches");
    }

    function updateAction(uint treeId, uint action, uint time) public payable onlyRole(QUEST_ROLE) {
        trees[treeId].onActionUntil = time;
        trees[treeId].action = action;
    }

    function gainExp(uint treeId, uint amount) public payable onlyRole(QUEST_ROLE) {
        trees[treeId].exp = trees[treeId].exp + amount;
        emit GainExp(treeId, amount);
    }

    function gainLevel(uint treeId) public payable onlyOwnerOf(treeId) {
        require(trees[treeId].level < 100 );
        require(trees[treeId].exp >= trees[treeId].level*100);
        require(trees[treeId].action == 0);
        //require enough PUDU Balance
        uint amount = trees[treeId].level*10**18;
        IERC20(TokenAddress).transferFrom(msg.sender, TreasuryAddress, amount*96/100);
        IERC20(TokenAddress).transferFrom(msg.sender, DevelopmentAddress, amount*4/100);
        trees[treeId].exp = trees[treeId].exp-trees[treeId].level*100;
        trees[treeId].level++;
        emit GainLevel(treeId);
    }

    function createNewTree() public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= currentPrice());
        uint id = trees.length;
        uint DNA = _generateRandomDNA();
        trees.push(TreeStruct(DNA, 1, 0, 1, 1, 0, 0));
        _mint(msg.sender, id);
        emit NewTree(id);

    }

    //Transfer Functions

    function transferDevelopmentAddress(address newDevelopment) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        DevelopmentAddress = newDevelopment;
    }

    function transferTreasuryAddress(address newTreasury) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        TreasuryAddress = newTreasury;
    }

    function transferTokenAddress(address newToken) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        TokenAddress = newToken;
    }

    function transferGameItemsAddress(address newGameItems) public payable onlyRole(DEFAULT_ADMIN_ROLE) {
        GameItemsAddress = newGameItems;
        gameItems = AbstractGameItems(GameItemsAddress);
    }
}