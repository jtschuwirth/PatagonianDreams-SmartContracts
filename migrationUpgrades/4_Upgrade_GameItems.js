const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const GameItems = artifacts.require('GameItems');
const GameItemsV2 = artifacts.require('GameItemsV2');

module.exports = async function (deployer) {
  const existing = await GameItems.deployed();
  await upgradeProxy(existing.address, TreeV2, { deployer });
};