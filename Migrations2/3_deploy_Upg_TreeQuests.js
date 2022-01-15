const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const TreeQuests = artifacts.require('TreeQuests');

module.exports = async function (deployer) {
  await deployProxy(TreeQuests, { deployer, initializer: 'initialize' });
};