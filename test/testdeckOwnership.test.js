const Tree = artifacts.require("Tree");

contract("Tree", (accounts) => {
    let alice = accounts[0];
    let bob = accounts[1];
    let tree;
    let expected_owner;


    before(async () => {
        crear_deck = await Tree.deployed();
    });

    it("account0 should be able to request the current Price", async () => {
        const result1 = await tree.currentPrice({from: alice});
        assert.equal(result1.receipt.status, true);
        const result2 = await tree.createNewTree({from: alice, value: 1})
        assert.equal(result2.receipt.status, true);
    })

});