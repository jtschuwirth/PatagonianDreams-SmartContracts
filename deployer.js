var Token = artifacts.require("Token");

module.exports = function(deployer) {
  deployer.deploy(Token);
};


var Tree = artifacts.require("Tree");

module.exports = function(deployer) {
  deployer.deploy(Tree);
};

var CleanRootsQuest = artifacts.require("CleanRootsQuest");

module.exports = function(deployer) {
  deployer.deploy(CleanRootsQuest);
};







//deploy 2
var TicketSale = artifacts.require("TicketSale");
var nftAddress = "0x7859D2a557E944a023DC3ADa594B3CeCbB8dc388";
var tokenSeller = "0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D";

module.exports = function(deployer) {
  deployer.deploy(TicketSale, nftAddress, tokenSeller);
};