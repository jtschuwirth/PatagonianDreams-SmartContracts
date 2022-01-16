const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const BasicRune = artifacts.require('BasicRune');

module.exports = async function (deployer) {
  await deployProxy(BasicRune, { deployer, initializer: 'initialize' });
};