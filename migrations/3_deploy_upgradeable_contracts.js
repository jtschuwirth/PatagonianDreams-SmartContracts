//truffle.cmd migrate --network testnet --reset

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Tree = artifacts.require('Tree');

module.exports = async function (deployer) {
  await deployProxy(Tree);
};