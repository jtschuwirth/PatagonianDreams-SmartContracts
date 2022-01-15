var Token = artifacts.require("Token");

module.exports = function(deployer) {
  deployer.deploy(Token);
};


var Tree = artifacts.require("Tree");

module.exports = function(deployer) {
  deployer.deploy(Tree);
};

var CleanRootsQuest = artifacts.require("CleanRootsQuest");

module.exports = function(deployer) {
  deployer.deploy(CleanRootsQuest);
};
//--------------------------------------------------------
//Upgradeable Deployer

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Tree = artifacts.require('Tree');

module.exports = async function (deployer) {
  await deployProxy(Tree, { deployer });
};


const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const CleanRootsQuest = artifacts.require('CleanRootsQuest');

module.exports = async function (deployer) {
  await deployProxy(CleanRootsQuest, { deployer });
};

// Upgrade Contract

const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Tree = artifacts.require('Tree');
const TreeV2 = artifacts.require('TreeV2');

module.exports = async function (deployer) {
  const existing = await Tree.deployed();
  await upgradeProxy(existing.address, TreeV2, { deployer });
};


const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const CleanRootsQuest = artifacts.require('CleanRootsQuest');
const CleanRootsQuestV2 = artifacts.require('CleanRootsQuestV2');

module.exports = async function (deployer) {
  const existing = await CleanRootsQuest.deployed();
  await upgradeProxy(existing.address, CleanRootsQuestV2, { deployer });
};



//deploy 2
var TicketSale = artifacts.require("TicketSale");
var nftAddress = "0x7859D2a557E944a023DC3ADa594B3CeCbB8dc388";
var tokenSeller = "0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D";

module.exports = function(deployer) {
  deployer.deploy(TicketSale, nftAddress, tokenSeller);
};