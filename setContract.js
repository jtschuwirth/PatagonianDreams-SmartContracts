const Web3 = require('web3');
const secret = require("./secret.json");

const testnet_mnemonic = secret.mnemonic;
const testnet_private_key = secret.privateKey;
const testnet_url = "https://api.s0.b.hmny.io";

const web3 = new Web3(testnet_url);
var account = web3.eth.accounts.privateKeyToAccount(testnet_private_key);
var BN = web3.utils.BN;

var TreeJson = require("./build/contracts/Tree.json");
var TreeABI = TreeJson["abi"];
var TreeAddress = TreeJson["networks"]["2"]["address"];
var TreeContract = new web3.eth.Contract(TreeABI, TreeAddress);

var TokenJson = require("./build/contracts/Pudu.json");
var TokenABI = TokenJson["abi"];
var TokenAddress = TokenJson["networks"]["2"]["address"];
var TokenContract = new web3.eth.Contract(TokenABI, TokenAddress);

var QuestJson = require("./build/contracts/TreeQuests.json");
var QuestABI = QuestJson["abi"];
var QuestAddress = QuestJson["networks"]["2"]["address"];
var QuestContract = new web3.eth.Contract(QuestABI, QuestAddress);

var GameItemsJson = require("./build/contracts/GameItems.json");
var GameItemsABI = GameItemsJson["abi"];
var GameItemsAddress = GameItemsJson["networks"]["2"]["address"];
var GameItemsContract = new web3.eth.Contract(GameItemsABI, GameItemsAddress);

function tx1() {
    var encodedABI = GameItemsContract.methods.grantRole(web3.utils.keccak256("MINTER_ROLE"), QuestAddress).encodeABI();
    var tx = {
        from: account.address,
        to: GameItemsAddress,
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
    var encodedABI = TokenContract.methods.grantRole(web3.utils.keccak256("MINTER_ROLE"), QuestAddress).encodeABI();
    var tx = {
        from: account.address,
        to: TokenAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 2")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx3()
        }).on('error', function(error){
            console.log(error)
        })
    });
}

function tx3() {
    var encodedABI = TreeContract.methods.grantRole(web3.utils.keccak256("QUEST_ROLE"), QuestAddress).encodeABI();
    var tx = {
        from: account.address,
        to: TreeAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 3")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx4()
        }).on('error', function(error){
            console.log(error)
        })
    });
}

function tx4() {
    var encodedABI = TreeContract.methods.transferTokenAddress(TokenAddress).encodeABI();
    var tx = {
        from: account.address,
        to: TreeAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 4")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx5()
        }).on('error', function(error){
            console.log(error)
        })
    });

}

function tx5() {
    var encodedABI = TreeContract.methods.transferGameItemsAddress(GameItemsAddress).encodeABI();
    var tx = {
        from: account.address,
        to: TreeAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 5")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx6()
        }).on('error', function(error){
            console.log(error)
        })
    }); 
}

function tx6() {
    var encodedABI = QuestContract.methods.transferTokenAddress(TokenAddress).encodeABI();
    var tx = {
        from: account.address,
        to: QuestAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 6")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx7()
        }).on('error', function(error){
            console.log(error)
        })
    }); 
}

function tx7() {
    var encodedABI = QuestContract.methods.transferGameItemsAddress(GameItemsAddress).encodeABI();
    var tx = {
        from: account.address,
        to: QuestAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 7")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx8()
        }).on('error', function(error){
            console.log(error)
        })
    }); 
}

function tx8() {
    var encodedABI = QuestContract.methods.transferTreeAddress(TreeAddress).encodeABI();
    var tx = {
        from: account.address,
        to: QuestAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };

    console.log("starting tx 8")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
            tx9()
        }).on('error', function(error){
            console.log(error)
        })
    }); 

}
function tx9() {
    var encodedABI = GameItemsContract.methods.grantRole(web3.utils.keccak256("BURNER_ROLE"), TreeAddress).encodeABI();
    var tx = {
        from: account.address,
        to: GameItemsAddress,
        gasPrice: 1000000000000,
        gasLimit: 1000000,
        data: encodedABI,
    };
    console.log("starting tx 9")
    web3.eth.accounts.signTransaction(tx, account.privateKey).then(function(data) {
        console.log("tx Signed")
        web3.eth.sendSignedTransaction(data.rawTransaction).on("receipt", function(receipt) {
            console.log(receipt)
        }).on('error', function(error){
            console.log(error)
        })
    });
}
tx1()

