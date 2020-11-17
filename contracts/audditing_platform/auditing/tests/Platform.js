const Platform = artifacts.require("Platform");
const truffleAssert = require("truffle-assertions");

contract("Platform", async (accounts) => {

    let owner;
    let NFT;
    let dataStore;
    let auditedContract;
    let auditor;
    let newDataStore;

    before(() => {
        owner = accounts[0];
        NFT = accounts[1];
        dataStore = accounts[2];
        auditedContract = accounts[3];
        auditor = accounts[4];
        newDataStore = accounts[5];
    });

    beforeEach(async () => {
        platform = await Platform.new(_NFT = NFT, _dataStore = dataStore, {from: owner});
    });

    describe("# constructor()", () => {

        it("Sets the NFT", async () => {
            assert.strictEqual(NFT, await platform.NFT());
        });

        it("Sets the data store", async () => {
            assert.strictEqual(dataStore, await platform.dataStore());
        });

    })

    describe("# completeAudit()", () => {

        it.skip("Emits the event CompletedAudit", async () => {
            const approved = true;

            // Apparently cannot easily encode into bytes in JS so IDK how to get the function to accept the "bytes" hash
            const hash = "00000000000000";

            const transaction = await platform.completeAudit(_contract = auditedContract, _approved = approved, _hash = hash, {from: auditor})

            assert.strictEqual("CompletedAudit", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
            assert.strictEqual(auditedContract, transaction.logs[0].args._contract);
            assert.strictEqual(approved, transaction.logs[0].args._approved);
            assert.strictEqual(hash, transaction.logs[0].args._hash);
       });

    })

    describe("# addAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.addAuditor(_auditor = auditor, {from: auditor}));
        });

        it("Reverts when paused", async () => {
            await platform.pause({from: owner});
            truffleAssert.reverts(platform.addAuditor(_auditor = auditor, {from: owner}));
        });

        it("Emits the event AddedAuditor", async () => {
            const transaction = await platform.addAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("AddedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# suspendAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.suspendAuditor(_auditor = auditor, {from: auditor}));
        });

        it("Emits the event SuspendedAuditor", async () => {
            const transaction = await platform.suspendAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("SuspendedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# migrate()", () => {

        it("Reverts when someone tries to migrate someone else", async () => {
            truffleAssert.reverts(platform.migrate(_auditor = auditor, {from: owner}));
        });

        it("Emits the event AuditorMigrated", async () => {
            const transaction = await platform.migrate(_auditor = auditor, {from: auditor});

            assert.strictEqual("AuditorMigrated", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(auditor, transaction.logs[0].args._sender);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# reinstateAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.reinstateAuditor(_auditor = auditor, {from: auditor}));
        });

        it("Reverts when paused", async () => {
            await platform.pause({from: owner});
            truffleAssert.reverts(platform.reinstateAuditor(_auditor = auditor, {from: owner}));
        });

        it("Emits the event ReinstatedAuditor", async () => {
            const transaction = await platform.reinstateAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("ReinstatedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# pauseDataStore()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.pauseDataStore({from: auditor}));
        });

        it("Emits the event PausedDataStore", async () => {
            const transaction = await platform.pauseDataStore({from: owner});

            assert.strictEqual("PausedDataStore", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._sender);
            assert.strictEqual(dataStore, transaction.logs[0].args._dataStore);
       });

    })

    describe("# unpauseDataStore()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.unpauseDataStore({from: auditor}));
        });

        it("Emits the event UnpausedDataStore", async () => {
            const transaction = await platform.unpauseDataStore({from: owner});

            assert.strictEqual("UnpausedDataStore", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._sender);
            assert.strictEqual(dataStore, transaction.logs[0].args._dataStore);
       });

    })

    describe("# changeDataStore()", () => {

        it("Reverts a non-owner call", async () => {
            truffleAssert.reverts(platform.changeDataStore(_dataStore = newDataStore, {from: auditor}));
        });

        it("Reverts when unpaused", async () => {
            truffleAssert.reverts(platform.changeDataStore(_dataStore = newDataStore, {from: owner}));
        });

        it("Emits the event ChangedDataStore", async () => {
            await platform.pause({from: owner});
            const transaction = await platform.changeDataStore(_dataStore = newDataStore, {from: owner});

            assert.strictEqual("ChangedDataStore", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(newDataStore, transaction.logs[0].args._dataStore);
       });

    })

})