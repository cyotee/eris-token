const Auditable = artifacts.require("Auditable");
const truffleAssert = require("truffle-assertions");

// NOTE: None of this will run unless you set the constructor of Auditable to public from internal
//       The compiler is a cunt. Make sure to set it back to internal after you run the tests!

contract("Auditable", async (accounts) => {

    let owner;
    let auditor;
    let platform;
    let hash;
    let newAuditor;
    let newPlatform;
    let newHash;
    let auditable;
    let randomStranger;
    let randomHash;

    before(() => {
        owner = accounts[0];
        auditor = accounts[1];
        platform = accounts[2];
        hash = accounts[3];
        newAuditor = accounts[4];
        newPlatform = accounts[5];
        newHash = accounts[6];
        randomStranger = accounts[7];
        randomHash = accounts[8];
    });

    beforeEach(async () => {
        auditable = await Auditable.new(_auditor = auditor, _platform = platform, {from: owner});
    });

    describe("# constructor()", () => {

        it("Sets the auditor", async () => {
            assert.strictEqual(auditor, await auditable.auditor());
        });

        it("Sets the platform", async () => {
            assert.strictEqual(platform, await auditable.platform());
        });

    })

    describe("# setContractCreationHash()", () => {

        it("Sets the contractCreationHash", async () => {
            const initialHash = await auditable.contractCreationHash();

            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            
            const postHash = await auditable.contractCreationHash();
            
            assert.notStrictEqual(initialHash, postHash);
            assert.strictEqual(hash, postHash);
        });

        it("Emits the event CreationHashSet", async () => {
            const transaction = await auditable.setContractCreationHash(_hash = hash, {from: owner});

            assert.strictEqual("CreationHashSet", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(hash, transaction.logs[0].args._hash);
       });

        it("Reverts a non-owner call", async () => {
            const initialHash = await auditable.contractCreationHash();

            truffleAssert.reverts(auditable.setContractCreationHash(_hash = hash, {from: auditor}));
            
            const postHash = await auditable.contractCreationHash();
            
            assert.strictEqual(initialHash, postHash);
        });

        it("Reverts post approved audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.approveAudit(_hash = hash, {from: auditor});

            const initialHash = await auditable.contractCreationHash();

            truffleAssert.reverts(auditable.setContractCreationHash(_hash = newHash, {from: owner}));
            
            const postHash = await auditable.contractCreationHash();
            
            assert.strictEqual(initialHash, postHash);
        });

        it("Reverts post opposed audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.opposeAudit(_hash = hash, {from: auditor});

            const initialHash = await auditable.contractCreationHash();

            truffleAssert.reverts(auditable.setContractCreationHash(_hash = newHash, {from: owner}));
            
            const postHash = await auditable.contractCreationHash();
            
            assert.strictEqual(initialHash, postHash);
        });

        it("Reverts after hash was already set", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});

            const initialHash = await auditable.contractCreationHash();

            truffleAssert.reverts(auditable.setContractCreationHash(_hash = newHash, {from: owner}));
            
            const postHash = await auditable.contractCreationHash();
            
            assert.strictEqual(initialHash, postHash);
        });

    })

    describe("# setAuditor()", () => {

        it("Sets the auditor when owner calls", async () => {
            const initialAuditor = await auditable.auditor();

            await auditable.setAuditor(_auditor = newAuditor, {from: owner});
            
            const postAuditor = await auditable.auditor();
            
            assert.notStrictEqual(initialAuditor, postAuditor);
            assert.strictEqual(newAuditor, postAuditor);
        });

        it("Sets the auditor when auditor calls", async () => {
            const initialAuditor = await auditable.auditor();

            await auditable.setAuditor(_auditor = newAuditor, {from: auditor});
            
            const postAuditor = await auditable.auditor();
            
            assert.notStrictEqual(initialAuditor, postAuditor);
            assert.strictEqual(newAuditor, postAuditor);
        });

        it("Reverts a non-owner, non-auditor call ", async () => {
            const initialAuditor = await auditable.auditor();

            truffleAssert.reverts(auditable.setAuditor(_auditor = newAuditor, {from: randomStranger}));
            
            const postAuditor = await auditable.auditor();
            
            assert.strictEqual(initialAuditor, postAuditor);
        });

        it("Reverts post audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.approveAudit(_hash = hash, {from: auditor});

            const initialAuditor = await auditable.auditor();

            truffleAssert.reverts(auditable.setAuditor(_auditor = newAuditor, {from: owner}));
            
            const postAuditor = await auditable.auditor();
            
            assert.notStrictEqual(initialAuditor, newAuditor);
            assert.strictEqual(initialAuditor, postAuditor);
        });

        it("Emits the event SetAuditor", async () => {
            const transaction = await auditable.setAuditor(_auditor = newAuditor, {from: auditor});

            assert.strictEqual("SetAuditor", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(auditor, transaction.logs[0].args._sender);
            assert.strictEqual(newAuditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# setPlatform()", () => {

        it("Sets the platform when owner calls", async () => {
            const initialPlatform = await auditable.platform();

            await auditable.setPlatform(_platform = newPlatform, {from: owner});
            
            const postPlatform = await auditable.platform();
            
            assert.notStrictEqual(initialPlatform, postPlatform);
            assert.strictEqual(newPlatform, postPlatform);
        });

        it("Sets the platform when auditor calls", async () => {
            const initialPlatform = await auditable.platform();

            await auditable.setPlatform(_platform = newPlatform, {from: auditor});
            
            const postPlatform = await auditable.platform();
            
            assert.notStrictEqual(initialPlatform, postPlatform);
            assert.strictEqual(newPlatform, postPlatform);
        });

        it("Reverts a non-owner, non-auditor call ", async () => {
            const initialPlatform = await auditable.platform();

            truffleAssert.reverts(auditable.setPlatform(_platform = newPlatform, {from: randomStranger}));
            
            const postPlatform = await auditable.platform();
            
            assert.strictEqual(initialPlatform, postPlatform);
        });

        it("Reverts post audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.approveAudit(_hash = hash, {from: auditor});

            const initialPlatform = await auditable.platform();

            truffleAssert.reverts(auditable.setPlatform(_platform = newPlatform, {from: owner}));
            
            const postPlatform = await auditable.platform();
            
            assert.notStrictEqual(initialPlatform, newPlatform);
            assert.strictEqual(initialPlatform, postPlatform);
        });

        it("Emits the event SetPlatform", async () => {
            const transaction = await auditable.setPlatform(_platform = newPlatform, {from: owner})

            assert.strictEqual("SetPlatform", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._sender);
            assert.strictEqual(newPlatform, transaction.logs[0].args._platform);
       });

    })

    describe("# approveAudit()", () => {

        it("Reverts a non-auditor call", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.approveAudit(_hash = hash, {from: owner}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts when creation hash not set", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.approveAudit(_hash = hash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts when hashes do not match", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.approveAudit(_hash = randomHash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts post audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.opposeAudit(_hash = hash, {from: auditor});

            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.approveAudit(_hash = hash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isTrue(initialAudited);
            assert.isFalse(initialApproved);
            assert.isTrue(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Approves the audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});

            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            await auditable.approveAudit(_hash = hash, {from: auditor});

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isTrue(postAudited);
            assert.isTrue(postApproved);            
        });

        it("Emits the event ApprovedAudit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});

            const transaction = await auditable.approveAudit(_hash = hash, {from: auditor});

            assert.strictEqual("ApprovedAudit", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

    describe("# opposeAudit()", () => {

        it("Reverts a non-auditor call", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.opposeAudit(_hash = hash, {from: owner}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts when creation hash not set", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.opposeAudit(_hash = hash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts when hashes do not match", async () => {
            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.opposeAudit(_hash = randomHash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isFalse(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Reverts post audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});
            await auditable.approveAudit(_hash = hash, {from: auditor});

            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            truffleAssert.reverts(auditable.opposeAudit(_hash = hash, {from: auditor}));

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isTrue(initialAudited);
            assert.isTrue(initialApproved);
            assert.isTrue(postAudited);
            assert.isTrue(postApproved);            
        });

        it("Opposes the audit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});

            const initialAudited = await auditable.audited();
            const initialApproved = await auditable.approved();

            await auditable.opposeAudit(_hash = hash, {from: auditor});

            const postAudited = await auditable.audited();
            const postApproved = await auditable.approved();
            
            assert.isFalse(initialAudited);
            assert.isFalse(initialApproved);
            assert.isTrue(postAudited);
            assert.isFalse(postApproved);            
        });

        it("Emits the event OpposedAudit", async () => {
            await auditable.setContractCreationHash(_hash = hash, {from: owner});

            const transaction = await auditable.opposeAudit(_hash = hash, {from: auditor});

            assert.strictEqual("OpposedAudit", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(auditor, transaction.logs[0].args._auditor);
       });

    })

})