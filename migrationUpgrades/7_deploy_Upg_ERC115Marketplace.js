const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const ERC1155Marketplace = artifacts.require("ERC1155Marketplace");

let PayoutAddress = "0x867df63D1eEAEF93984250f78B4bd83C70652dcE";

var TokenJson = require("./build/contracts/PTG.json");
var TokenAddress = TokenJson["networks"]["2"]["address"];

var GameItemsJson = require("./build/contracts/GameItems.json");
var GameItemsAddress = GameItemsJson["networks"]["2"]["address"];

module.exports = async function (deployer) {
  await deployProxy(ERC1155Marketplace, PayoutAddress, TokenAddress, GameItemsAddress, { deployer, initializer: "initialize" });
};