//truffle.cmd migrate --network testnet --reset

var CleanRootsQuest = artifacts.require("CleanRootsQuest");

module.exports = function(deployer) {
  deployer.deploy(CleanRootsQuest);
};