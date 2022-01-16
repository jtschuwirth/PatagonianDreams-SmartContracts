//truffle compile --all
//truffle.cmd migrate --network testnet --reset

//truffle.cmd migrate --network testnet --reset --skip-dry-run

const Migrations = artifacts.require("Migrations");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
