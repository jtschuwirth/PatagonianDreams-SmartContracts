// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


contract Animal is ERC721Upgradeable, AccessControlUpgradeable {

    bytes32 public constant QUEST_ROLE = keccak256("QUEST_ROLE");
    bytes32 public constant UPG_ROLE = keccak256("UPG_ROLE");

    event GainLevel(uint256 animalId);
    event GainExp(uint256 animalId, uint256 amount);

    uint256 Digits;
    uint256 Modulus;

    address payable DevelopmentAddress;
    address payable TreasuryAddress;
    address TokenAddress;

    struct AnimalStruct {
        uint256 DNA;
        uint256 level;
        uint256 exp;
        uint256 stamina;
        uint256 maxStamina;
    }
    
    mapping(uint256 => AnimalStruct) animals;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private animalCounter;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function initialize() initializer public {
        Digits = 16;
        Modulus = 10 ** Digits;

        DevelopmentAddress = payable(0x7C50D01C7Ba0EDE836bDA6daC88A952f325756e3);
        TreasuryAddress = payable(0xa691623968855b91A066661b0552a7D3764c9a64);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ERC721_init("Patagonic Animal", "pAnimal");
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

    function _generateRandomDNA() internal view returns (uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked(vrf())));
        return rand % Modulus;
    }

    function gainLevel(uint256 animalId, address user) external onlyRole(UPG_ROLE) {
        uint256 amount = animals[animalId].level*10**18;
        require(IERC20Upgradeable(TokenAddress).balanceOf(user)>= amount);
        IERC20Upgradeable(TokenAddress).transferFrom(user, TreasuryAddress, amount*96/100);
        IERC20Upgradeable(TokenAddress).transferFrom(user, DevelopmentAddress, amount*4/100);
        animals[animalId].exp = 0;
        animals[animalId].level++;
        emit GainLevel(animalId);
    }

    function gainExp(uint256 animalId, uint256 amount) external onlyRole(QUEST_ROLE) {
        if (animals[animalId].level*100 <= animals[animalId].exp + amount) {
            animals[animalId].exp = animals[animalId].level*100;
        } else {
            animals[animalId].exp = animals[animalId].exp + amount;
        }
        emit GainExp(animalId, amount);
    }
}