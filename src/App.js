import React, { useState, useEffect } from "react";
import { Table, Dropdown } from 'react-bootstrap';
import Countdown from 'react-countdown';
const bootstrap = require('bootstrap')
const Web3 = require('web3');
const web3 = new Web3(window.ethereum);
var BN = web3.utils.BN;

var TreeJson = require("../build/contracts/Tree.json");
var TreeABI = TreeJson["abi"];
var TreeAddress = TreeJson["networks"]["2"]["address"];
var TreeContract = new web3.eth.Contract(TreeABI, TreeAddress);

var TokenJson = require("../build/contracts/Pudu.json");
var TokenABI = TokenJson["abi"];
var TokenAddress = TokenJson["networks"]["2"]["address"];
var TokenContract = new web3.eth.Contract(TokenABI, TokenAddress);

var QuestJson = require("../build/contracts/TreeQuests.json");
var QuestABI = QuestJson["abi"];
var QuestAddress = QuestJson["networks"]["2"]["address"];
var QuestContract = new web3.eth.Contract(QuestABI, QuestAddress);

var GameItemsJson = require("../build/contracts/GameItems.json");
var GameItemsABI = GameItemsJson["abi"];
var GameItemsAddress = GameItemsJson["networks"]["2"]["address"];
var GameItemsContract = new web3.eth.Contract(GameItemsABI, GameItemsAddress);

function App() {
    const [Address, setAddress] = useState(null);
    const [Supply, setSupply] = useState(null);
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
            setTreeData()
      
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
            await TreeContract.methods.createNewTree().send({from: Address, value: value}).then(function(receipt) {
                setTreeData();
            })
        } catch (error) {
            console.error(error);
        }
    }

    async function gainLevel(id) {
        try {
            await TreeContract.methods.gainLevel(id).send({from: Address}).then(function(receipt) {
                setTreeData();
            })
        } catch (error) {
            console.error(error);
        }
    }

    async function requestCurrentLevelPrice(id) {
        let currentPrice;
        try {
            currentPrice = await TreeContract.methods.treeLevel(id).call()
            let exp = new BN(10, 10).pow(new BN(18, 10));
            currentPrice = new BN(currentPrice).mul(exp);
        } catch (error) {
            console.error(error);
        }
        return currentPrice
    }

    async function approveToken(id) {
        let valueToken = await requestCurrentLevelPrice(id)
        try {
            await TokenContract.methods.approve(TreeAddress, valueToken).send({from: Address})
        } catch (error) {
            console.error(error);
        }
    }

    async function startQuest(id) {
        try {
            await QuestContract.methods.startQuest2(id).send({from: Address}).then(function(receipt) {
                setTreeData();
            })
        } catch (error) {
            console.error(error);
        }
    }

    async function completeQuest(id) {
        try {
            await QuestContract.methods.completeQuest2(id).send({from: Address}).then(function(receipt) {
                setTreeData();
            })

        } catch (error) {
            console.error(error);
        }
    }

    async function cancelQuest(id) {
        try {
            await QuestContract.methods.cancelQuest2(id).send({from: Address}).then(function(receipt) {
                setTreeData();
            })

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
        let level;
        let exp;
        let quest;
        try {
            level = await TreeContract.methods.treeLevel(id).call()
        } catch (error) {
            console.error(error);
        }
        try {
            exp = await TreeContract.methods.treeExp(id).call()
        } catch (error) {
            console.error(error);
        }
        try {
            quest = await TreeContract.methods.actionStatus(id).call()
        } catch (error) {
            console.error(error);
        }
        return {id: id, level: level, exp: exp, onQuestUntil: quest}
    }

    async function setTreeData() {
        ownedTrees(Address).then((result) => {
            setAddressData(result);
        });
    }

    function RenderData(props) {
        return (
            <tr key={props.index}>
                <td>{props.tree.id}</td>
                <td>{props.tree.exp}</td>
                <td>{props.tree.level}</td>
                <td>{<RenderTimer tree={props.tree}/>}</td>
                <td><button onClick={ () => startQuest(props.tree.id)}>Start Quest</button></td>
                <td><button onClick={ () => completeQuest(props.tree.id)}>Complete Quest</button></td>
                <td><button onClick={ () => cancelQuest(props.tree.id)}>Cancel Quest</button></td>
                <td><button onClick={ () => gainLevel(props.tree.id)}>Gain Level</button></td>
                <td><button onClick={ () => approveToken(props.tree.id)}>Approve Token for LevelUp</button></td>
            </tr>
        )
    }

    async function puduSupply() {
        try {
            var supply = await TokenContract.methods.totalSupply().call()
            supply = supply/(10**18)
        } catch (error) {
            console.error(error);
        }
        setSupply(supply)
    }

    useEffect(() => {
        isMetaMaskConnected().then((connected) => {
            if (connected) {
                // metamask is connected
                connectMetaMask()
                puduSupply()
            } else {
                // metamask is not connected
                setAddress(null)
            }
        });

    },[Address]);

    return (
        <div>
            <div>{Address}</div>
            <div>Total Pudu Supply: {Supply}</div>
            <div>
                <div>
                    <button onClick={ () => connectMetaMask()}>Connect Metamask</button>
                    <button onClick={ () => buyNewTree()}>Buy new Tree</button>
                </div>
                <button onClick={ () => approveTreasury()}>Approve Treasury Spending</button>
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
                        <th>Gain level</th>
                    </tr>
                </thead>
                <tbody>
                    {AddressData.map((_, index) => <RenderData tree={_} index={index}/>)}
                </tbody>
            </Table>
        </div>
    )
}

function RenderTimer(props) {
    let timer = props.tree.onQuestUntil*1000;
    if (props.tree.onQuestUntil == 0) {
        timer = Math.round(Date.now())
    } else if (timer < Date.now()) {
        return "Quest Completed"
    } 
    return (
    <Countdown date={timer} >
    </Countdown>
    )
}



export default App;