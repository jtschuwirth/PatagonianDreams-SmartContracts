var TokenVestingFounders = artifacts.require("TokenVestingFounders");
var TokenSplitterFounders = artifacts.require("TokenSplitterFounders");

let startTimestamp;
let durationSeconds = 60*60*24*30;
let payees = [];
let shares = [];

module.exports = async function(deployer) {
    await deployer.deploy(TokenSplitterFounders, payees, shares);
    await deployer.deploy(TokenVestingFounders, TokenSplitterFounders.address, startTimestamp, durationSeconds);

};