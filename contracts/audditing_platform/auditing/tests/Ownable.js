const Ownable = artifacts.require("Ownable");
const truffleAssert = require("truffle-assertions");

// NOTE: None of this will run unless you set the constructor of Ownable to public from internal
//       The compiler is a cunt. Make sure to set it back to internal after you run the tests!

contract("Ownable", async (accounts) => {

    let owner;
    let newOwner;
    let ownable;
    const address0 = "0x0000000000000000000000000000000000000000";

    before(() => {
        owner = accounts[0];
        newOwner = accounts[1];
    });

    beforeEach(async () => {
        ownable = await Ownable.new({from: owner});
    });

    describe("# constructor()", () => {

        it("Sets the owner", async () => {
            assert.strictEqual(owner, await ownable.owner());
        });

    })

    describe("# transferOwnership()", () => {

        it("Reverts a non-owner call", async () => {
            const initialOwner = await ownable.owner();

            truffleAssert.reverts(ownable.transferOwnership(_newOwner = newOwner, {from: newOwner}));

            const postOwner = await ownable.owner();

            assert.strictEqual(initialOwner, postOwner);
        });

        it("Reverts transfer to address(0)", async () => {
            const initialOwner = await ownable.owner();

            truffleAssert.reverts(ownable.transferOwnership(_newOwner = address0, {from: owner}));

            const postOwner = await ownable.owner();

            assert.strictEqual(initialOwner, postOwner);
        });

        it("Transfers ownership", async () => {
            const initialOwner = await ownable.owner();

            await ownable.transferOwnership(_newOwner = newOwner, {from: owner});

            const postOwner = await ownable.owner();

            assert.notStrictEqual(initialOwner, newOwner);
            assert.strictEqual(postOwner, newOwner);
        });

        it("Emits the event OwnershipTransferred", async () => {
            const transaction = await ownable.transferOwnership(_newOwner = newOwner, {from: owner});

            assert.strictEqual("OwnershipTransferred", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._previousOwner);
            assert.strictEqual(newOwner, transaction.logs[0].args._newOwner);
       });

    })

    describe("# renounceOwnership()", () => {

        it("Reverts a non-owner call", async () => {
            const initialOwner = await ownable.owner();

            truffleAssert.reverts(ownable.renounceOwnership({from: newOwner}));

            const postOwner = await ownable.owner();

            assert.strictEqual(initialOwner, postOwner);
        });

        it("Gives ownership to address(0)", async () => {
            const initialOwner = await ownable.owner();

            await ownable.renounceOwnership({from: owner});

            const postOwner = await ownable.owner();

            assert.notStrictEqual(initialOwner, postOwner);
            assert.strictEqual(address0, postOwner);
        });

        it("Emits the event OwnershipTransferred", async () => {
            const transaction = await ownable.renounceOwnership({from: owner});

            assert.strictEqual("OwnershipTransferred", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._previousOwner);
            assert.strictEqual(address0, transaction.logs[0].args._newOwner);
       });

    })

})