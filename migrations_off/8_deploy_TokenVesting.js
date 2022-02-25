var TokenVesting = artifacts.require("TokenVesting");
var TokenSplitter = artifacts.require("TokenSplitter");

let startTimestamp;
let durationSeconds = 60*60*24*30;
let payees = [];
let shares = [];

module.exports = async function(deployer) {
    await deployer.deploy(TokenSplitter, payees, shares);
    await deployer.deploy(TokenVesting, TokenSplitter.address, startTimestamp, durationSeconds);

};