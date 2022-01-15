const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Tree = artifacts.require('Tree');
const TreeV2 = artifacts.require('TreeV2');

module.exports = async function (deployer) {
  const existing = await Tree.deployed();
  await upgradeProxy(existing.address, TreeV2, { deployer });
};