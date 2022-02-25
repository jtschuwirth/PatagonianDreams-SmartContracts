var TokenVestingGameDev = artifacts.require("TokenVestingGameDev ");
var TokenSplitterGameDev  = artifacts.require("TokenSplitterGameDev ");

let startTimestamp;
let durationSeconds;
let FutureDevelopmentWallet;
let MarketingWallet;
let payees = [FutureDevelopmentWallet, MarketingWallet];
let shares = [10, 5];

module.exports = async function(deployer) {
    await deployer.deploy(TokenSplitterGameDev , payees, shares);
    await deployer.deploy(TokenVestingGameDev , TokenSplitterGameDev .address, startTimestamp, durationSeconds);

};