const Web3 = require('web3');
const secret = require("./secret.json");

const testnet_private_key = secret.privateKey;
const testnet_url = "https://api.s0.b.hmny.io";

const web3 = new Web3(testnet_url);
var account = web3.eth.accounts.privateKeyToAccount(testnet_private_key);

var MarketplaceJson = require("./build/contracts/Marketplace.json");
var MarketplaceABI = MarketplaceJson["abi"];
var MarketplaceAddress = MarketplaceJson["networks"]["2"]["address"];
var MarketplaceContract = new web3.eth.Contract(MarketplaceABI, MarketplaceAddress);

var TokenJson = require("./build/contracts/PTG.json");
var TokenAddress = TokenJson["networks"]["2"]["address"];

var GameItemsJson = require("./build/contracts/GameItems.json");
var GameItemsAddress = GameItemsJson["networks"]["2"]["address"];

function tx1() {
    var encodedABI = MarketplaceContract.methods.transferTokenAddress(TokenAddress).encodeABI();
    var tx = {
        from: account.address,
        to: MarketplaceAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 1")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx2()
        }).on('error', function(error){
            console.log(error)
        })
    });
}

function tx2() {
    var encodedABI = MarketplaceContract.methods.transferGameItemsAddress(GameItemsAddress).encodeABI();
    var tx = {
        from: account.address,
        to: MarketplaceAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 2")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
        }).on('error', function(error){
            console.log(error)
        })
    }); 
}

tx1();