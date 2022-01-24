const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const TreeQuests = artifacts.require('TreeQuestsV2');
const TreeQuestsV2 = artifacts.require('TreeQuestsV3');

module.exports = async function (deployer) {
  const existing = await TreeQuests.deployed();
  await upgradeProxy(existing.address, TreeQuestsV2, { deployer });
};