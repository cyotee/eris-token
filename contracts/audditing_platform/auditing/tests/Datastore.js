const Datastore = artifacts.require("Datastore");
const truffleAssert = require("truffle-assertions");

contract("Datastore", async (accounts) => {

    // The owner is the platform and not a person
    let owner;
    let datastore;
    let contract;
    let auditor;
    let newDataStore;
    const address0 = "0x0000000000000000000000000000000000000000";

    before(() => {
        owner = accounts[0];
        contract = accounts[1];
        auditor = accounts[2];
        newDataStore = accounts[3];
    });

    beforeEach(async () => {
        datastore = await Datastore.new({from: owner});
    });

    describe("# hasAuditorRecord()", () => {

        it("Finds the record", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            const postExists = await datastore.hasAuditorRecord(auditor);

            assert.isFalse(initialExists);
            assert.isTrue(postExists);
        });

        it("Returns false when there is no record", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            assert.isFalse(initialExists);
        });

    });

    describe("# isAuditor()", () => {

        it("Finds the record as true", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);
            
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            
            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isFalse(initialExists);
            assert.isFalse(initialAuditor);
            assert.isTrue(postExists);
            assert.isTrue(postAuditor);
        });

        it("Finds the record as false", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});
            
            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isFalse(initialExists);
            assert.isFalse(initialAuditor);
            assert.isTrue(postExists);
            assert.isFalse(postAuditor);
        });

        it("Returns false when there is no record", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);
            assert.isFalse(initialExists);
            assert.isFalse(initialAuditor);
        });

    });

    describe("# hasContractRecord()", () => {

        it("Returns false when there is no record", async () => {
            const initialExists = await datastore.hasContractRecord(contract);
            assert.isFalse(initialExists);
        });

    });

    describe("# auditorDetails()", () => {

        it("Reverts when no auditor record in store", async () => {
            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.auditorDetails(_auditor = auditor, {from: owner}));

            assert.isFalse(initialAuditor);
        });

    });

    describe("# auditorApprovedContract()", () => {

        it("Reverts when no auditor record in store", async () => {
            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.auditorApprovedContract(_auditor = auditor, index = 0, {from: owner}));

            assert.isFalse(initialAuditor);
        });

    });

    describe("# auditorOpposedContract()", () => {

        it("Reverts when no auditor record in store", async () => {
            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.auditorOpposedContract(_auditor = auditor, index = 0, {from: owner}));

            assert.isFalse(initialAuditor);
        });

    });

    describe("# contractDetails()", () => {

        it("Reverts when no contract record in store", async () => {
            const initialContract = await datastore.hasContractRecord(contract);

            truffleAssert.reverts(datastore.contractDetails(_contract = contract, {from: owner}));

            assert.isFalse(initialContract);
        });

    });

    describe("# addAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.addAuditor(_auditor = auditor, {from: auditor}));

            const postAuditor = await datastore.hasAuditorRecord(auditor);

            assert.isFalse(initialAuditor);
            assert.isFalse(postAuditor);
        });

        it("Reverts when paused", async () => {
            await datastore.pause({from: owner});

            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.addAuditor(_auditor = auditor, {from: owner}));

            const postAuditor = await datastore.hasAuditorRecord(auditor);

            assert.isFalse(initialAuditor);
            assert.isFalse(postAuditor);
        });

        it("Reverts when auditor exists", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});

            const initialAuditor = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.addAuditor(_auditor = auditor, {from: owner}));

            assert.isTrue(initialAuditor);
        });

        it("Adds the auditor", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            
            await datastore.addAuditor(_auditor = auditor, {from: owner});

            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isFalse(initialExists);
            assert.isTrue(postExists);
            assert.isTrue(postAuditor);
        });

        it("Emits the event AddedAuditor", async () => {
            const transaction = await datastore.addAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("AddedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# suspendAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});

            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.suspendAuditor(_auditor = auditor, {from: auditor}));

            const postAuditor = await datastore.isAuditor(auditor);

            assert.isTrue(initialAuditor);
            assert.isTrue(postAuditor);
        });

        it("Reverts when no record of auditor", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);

            truffleAssert.reverts(datastore.suspendAuditor(_auditor = auditor, {from: owner}));

            assert.isFalse(initialExists);
        });

        it("Reverts when auditor is suspended", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.suspendAuditor(_auditor = auditor, {from: owner}));

            assert.isTrue(initialExists);
            assert.isFalse(initialAuditor);
        });

        it("Suspends the auditor", async () => {            
            await datastore.addAuditor(_auditor = auditor, {from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isTrue(initialExists);
            assert.isTrue(initialAuditor);
            assert.isTrue(postExists);
            assert.isFalse(postAuditor);
        });

        it("Emits the event SuspendedAuditor", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            const transaction = await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("SuspendedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# reinstateAuditor()", () => {

        it("Reverts a non-owner call", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.reinstateAuditor(_auditor = auditor, {from: auditor}));

            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isTrue(initialExists);
            assert.isFalse(initialAuditor);
            assert.isTrue(postExists);
            assert.isFalse(postAuditor);
        });

        it("Reverts when paused", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});
            await datastore.pause({from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.reinstateAuditor(_auditor = auditor, {from: owner}));

            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isTrue(initialExists);
            assert.isFalse(initialAuditor);
            assert.isTrue(postExists);
            assert.isFalse(postAuditor);
        });

        it("Reverts when no auditor record", async () => {
            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.reinstateAuditor(_auditor = auditor, {from: owner}));

            assert.isFalse(initialExists);
            assert.isFalse(initialAuditor);
        });

        it("Reverts when auditor is active", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);

            truffleAssert.reverts(datastore.reinstateAuditor(_auditor = auditor, {from: owner}));

            assert.isTrue(initialExists);
            assert.isTrue(initialAuditor);
        });

        it("Reinstates the auditor", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            const initialExists = await datastore.hasAuditorRecord(auditor);
            const initialAuditor = await datastore.isAuditor(auditor);
            
            await datastore.reinstateAuditor(_auditor = auditor, {from: owner});

            const postExists = await datastore.hasAuditorRecord(auditor);
            const postAuditor = await datastore.isAuditor(auditor);

            assert.isTrue(initialExists);
            assert.isFalse(initialAuditor);
            assert.isTrue(postExists);
            assert.isTrue(postAuditor);
        });

        it("Emits the event ReinstatedAuditor", async () => {
            await datastore.addAuditor(_auditor = auditor, {from: owner});
            await datastore.suspendAuditor(_auditor = auditor, {from: owner});

            const transaction = await datastore.reinstateAuditor(_auditor = auditor, {from: owner});

            assert.strictEqual("ReinstatedAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# linkDataStore()", () => {

        it("Reverts a non-owner call", async () => {
            const initialStore = await datastore.previousDatastore();

            truffleAssert.reverts(datastore.linkDataStore(_dataStore = newDataStore, {from: auditor}));

            const postStore = await datastore.previousDatastore();

            assert.strictEqual(address0, initialStore);
            assert.strictEqual(address0, postStore);
        });

        it("Changes the datastore", async () => {
            const initialStore = await datastore.previousDatastore();

            await datastore.linkDataStore(_dataStore = newDataStore, {from: owner});

            const postStore = await datastore.previousDatastore();

            assert.strictEqual(address0, initialStore);
            assert.strictEqual(newDataStore, postStore);
            assert.notStrictEqual(address0, newDataStore);
        });

        it("Emits the event LinkedDataStore", async () => {
            const transaction = await datastore.linkDataStore(_dataStore = newDataStore, {from: owner});

            assert.strictEqual("LinkedDataStore", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._owner);
            assert.strictEqual(newDataStore, transaction.logs[0].args._dataStore);
       });


    })

})