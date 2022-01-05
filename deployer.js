
//deploy 1
var Ticket = artifacts.require("Ticket");

module.exports = function(deployer) {
  deployer.deploy(Ticket);
};


//deploy 2
var TicketSale = artifacts.require("TicketSale");
var nftAddress;
var tokenSeller = "0xf577601a5eF1d5079Da672f01D7aB3b80dD2bd1D";
var currentPrice = 10*(10**18);

module.exports = function(deployer) {
  deployer.deploy(TicketSale, nftAddress, tokenSeller, currentPrice);
};