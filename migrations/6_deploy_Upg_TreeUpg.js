const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const TreeUpg = artifacts.require("TreeUpg");

module.exports = async function (deployer) {
  await deployProxy(TreeUpg, { deployer, initializer: "initialize" });
};