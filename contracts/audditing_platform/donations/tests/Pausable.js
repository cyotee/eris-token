const Pausable = artifacts.require("Pausable");
const truffleAssert = require("truffle-assertions");

// NOTE: None of this will run unless you set the constructor of Pausable to public from internal
//       The compiler is a cunt. Make sure to set it back to internal after you run the tests!

contract("Pausable", async (accounts) => {

    let owner;
    let notOwner;
    let pausable;

    before(() => {
        owner = accounts[0];
        notOwner = accounts[1];
    });

    beforeEach(async () => {
        pausable = await Pausable.new({from: owner});
    });

    describe("# pause()", () => {

        it("Sets paused to true", async () => {
            await pausable.pause();
            assert.isTrue(await pausable.paused());
        });

        it("Reverts a non-owner call", async () => {
            const initialPaused = await pausable.paused();

            truffleAssert.reverts(pausable.pause({from: notOwner}));

            const postPaused = await pausable.paused();

            assert.isFalse(initialPaused);
            assert.isFalse(postPaused);
        });

        it("Reverts after already in paused state", async () => {
            await pausable.pause({from: owner});

            const initialPaused = await pausable.paused();

            truffleAssert.reverts(pausable.pause({from: owner}));

            const postPaused = await pausable.paused();

            assert.isTrue(initialPaused);
            assert.isTrue(postPaused);
        });

        it("Emits the event Paused", async () => {
            const transaction = await pausable.pause({from: owner});

            assert.strictEqual("Paused", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._sender);
       });

    })

    describe("# unpause()", () => {

        it("Sets paused to false", async () => {
            await pausable.pause({from: owner});

            const initialPaused = await pausable.paused();

            await pausable.unpause();

            const postPaused = await pausable.paused();

            assert.isTrue(initialPaused);
            assert.isFalse(postPaused);
        });

        it("Reverts a non-owner call", async () => {
            await pausable.pause({from: owner});

            const initialPaused = await pausable.paused();

            truffleAssert.reverts(pausable.unpause({from: notOwner}));

            const postPaused = await pausable.paused();

            assert.isTrue(initialPaused);
            assert.isTrue(postPaused);
        });

        it("Reverts after already in unpaused state", async () => {
            const initialPaused = await pausable.paused();

            truffleAssert.reverts(pausable.unpause({from: owner}));

            const postPaused = await pausable.paused();

            assert.isFalse(initialPaused);
            assert.isFalse(postPaused);
        });

        it("Emits the event Unpaused", async () => {
            await pausable.pause({from: owner});
            const transaction = await pausable.unpause({from: owner});

            assert.strictEqual("Unpaused", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._sender);
       });

    })

})