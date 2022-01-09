import React, { useState, useEffect } from "react";
const Web3 = require('web3');
const web3 = new Web3(window.ethereum);
var BN = web3.utils.BN;

var TreeJson = require("../build/contracts/Tree.json");
var TreeABI = TreeJson["abi"];
var TreeAddress = TreeJson["networks"]["2"]["address"];
var TreeContract = new web3.eth.Contract(TreeABI, TreeAddress);

var TokenJson = require("../build/contracts/Token.json");
var TokenABI = TokenJson["abi"];
var TokenAddress = TokenJson["networks"]["2"]["address"];
var TokenContract = new web3.eth.Contract(TokenABI, TokenAddress);

var QuestJson = require("../build/contracts/CleanRootsQuest.json");
var QuestABI = QuestJson["abi"];
var QuestAddress = QuestJson["networks"]["2"]["address"];
var QuestContract = new web3.eth.Contract(QuestABI, QuestAddress);

function App() {
    const [Address, setAddress] = useState(null);

    async function isMetaMaskConnected() {
        const accounts = await web3.eth.getAccounts()
        return accounts.length > 0;
      }

    async function connectMetaMask() {
        try {
            const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
            const account = accounts[0];
            setAddress(account)
      
          } catch (error) {
            console.error(error);
          }
    }

    async function requestCurrentPrice() {
        let currentPrice;
        try {
            currentPrice = await TreeContract.methods.currentPrice().call()
        } catch (error) {
            console.error(error);
        }
        return currentPrice
    }

    async function buyNewTree() {
        let value = await requestCurrentPrice()
        try {
            await TreeContract.methods.createNewTree().send({from: Address, value: value})
        } catch (error) {
            console.error(error);
        }
    }

    async function gainLevel(id) {
        try {
            await TreeContract.methods.gainLevel(id).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function requestCurrentLevelPrice(id) {
        let currentLevel;
        try {
            currentLevel = await TreeContract.methods.neededAmount(id).call()
        } catch (error) {
            console.error(error);
        }
        return currentLevel
    }

    async function approveToken() {
        let valueToken = await requestCurrentLevelPrice(0)
        try {
            await TokenContract.methods.approve(TreeAddress, valueToken).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function changeQuestAddress() {
        try {
            await TreeContract.methods.transferQuestContract(QuestAddress).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function startQuest(id) {
        try {
            await QuestContract.methods.startQuest(id).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function completeQuest(id) {
        try {
            await QuestContract.methods.completeQuest(id).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function cancelQuest(id) {
        try {
            await QuestContract.methods.cancelQuest(id).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    useEffect(() => {
        isMetaMaskConnected().then((connected) => {
            if (connected) {
                // metamask is connected
                connectMetaMask()
            } else {
                // metamask is not connected
                setAddress(null)
            }
        });
    },[]);

    return (
        <div>
            <div>{Address}</div>
            <div>
                <div>
                    <button onClick={ () => connectMetaMask()}>Connect Metamask</button>
                    <button onClick={ () => buyNewTree()}>Buy new Tree</button>
                    <button onClick={ () => changeQuestAddress()}>Change Questing Address</button>
                </div>
                <div>
                    <button onClick={ () => startQuest(0)}>Start Quest</button>
                    <button onClick={ () => completeQuest(0)}>Complete Quest</button>
                    <button onClick={ () => cancelQuest(0)}>Cancel Quest</button>
                </div>
                <div>
                    <button onClick={ () => approveToken()}>Approve Token use</button>
                    <button onClick={ () => gainLevel(0)}>Gain Level</button>
                </div>
            </div>
        </div>
    )
}


export default App;