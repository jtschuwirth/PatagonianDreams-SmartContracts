const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const GameItems = artifacts.require("GameItems");

module.exports = async function (deployer) {
  await deployProxy(GameItems, { deployer, initializer: "initialize" });
};