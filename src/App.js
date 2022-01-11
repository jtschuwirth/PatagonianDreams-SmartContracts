import React, { useState, useEffect } from "react";
import { Table, Dropdown } from 'react-bootstrap';
const bootstrap = require('bootstrap')
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
    const [AddressData, setAddressData] = useState([]);

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

    async function approveTreasury() {
        let exp = new BN(10, 10).pow(new BN(18, 10));
        let valueToken = new BN(400000, 10).mul(exp);
        try {
            await TokenContract.methods.approve(QuestAddress, valueToken).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function ownedTrees(address) {
        let trees = [];
        for (var i=0;i<10;i++) {
            try {
              let owner = await TreeContract.methods.ownerOf(i).call();
              owner = owner.toLowerCase();
              if (owner == address) {
                  let data = await requestTreeData(i);
                  trees.push(data)
              }
            } catch(error) {
            }
        }
        return trees
    }

    async function requestTreeData(id) {
        let level = 0;
        let exp = 0;
        let quest;
        try {
            quest = await TreeContract.methods.questStatus(id).call()
        } catch (error) {
            console.error(error);
        }
        return {id: id, level: level, exp: exp, onQuestUntil: quest}
    }

    function renderData(tree, index) {
        return (
            <tr key={index}>
                <td>{tree.id}</td>
                <td>{tree.exp}</td>
                <td>{tree.level}</td>
                <td>{tree.onQuestUntil}</td>
                <td><button onClick={ () => startQuest(tree.id)}>Start Quest</button></td>
                <td><button onClick={ () => completeQuest(tree.id)}>Complete Quest</button></td>
                <td><button onClick={ () => cancelQuest(tree.id)}>Cancel Quest</button></td>
                <td><button onClick={ () => gainLevel(tree.id)}>Gain Level</button></td>
            </tr>
        )
    }

    useEffect(() => {
        isMetaMaskConnected().then((connected) => {
            if (connected) {
                // metamask is connected
                connectMetaMask()
                ownedTrees(Address).then((result) => {
                    console.log(result)
                    setAddressData(result);
                });
            } else {
                // metamask is not connected
                setAddress(null)
            }
        });


    },[Address]);

    return (
        <div>
            <div>{Address}</div>
            <div>
                <div>
                    <button onClick={ () => connectMetaMask()}>Connect Metamask</button>
                    <button onClick={ () => buyNewTree()}>Buy new Tree</button>
                    <button onClick={ () => approveToken()}>Approve Token use</button>
                </div>
                <div>
                <button onClick={ () => changeQuestAddress()}>Change Questing Address</button>
                    <button onClick={ () => approveTreasury()}>Approve Treasury Spending</button>
                </div>
            </div>
            <Table striped bordered hover size="sm" variant="dark">
                <thead>
                    <tr>
                        <th>Tree Id</th>
                        <th>Tree Exp</th>
                        <th>Tree Level</th>
                        <th>Quest Timer</th>
                        <th>Start Quest</th>
                        <th>Complete Quest</th>
                        <th>Cancel Quest</th>
                    </tr>
                </thead>
                <tbody>
                    {AddressData.map((_, index) => renderData(_, index))}
                </tbody>
            </Table>
        </div>
    )
}


export default App;