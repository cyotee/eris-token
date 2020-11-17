const Auditable = artifacts.require("Auditable");
const truffleAssert = require("truffle-assertions");

contract("Auditable", async (accounts) => {

     let owner;
     let auditor;
     let auditable;
     let auditedContract;
     let stranger;

     before(() => {
          owner = accounts[0];
          auditor = accounts[1];
          auditedContract = accounts[2];
          stranger = accounts[3];
     });

     beforeEach(async () => {
          auditable = await Auditable.new(_auditor = auditor, _auditedContract = auditedContract, {from: owner});
     });

     describe("# constructor()", () => {

          it("Sets the auditor address", async () => {
               assert.strictEqual(auditor, await auditable.auditor());
          });

          it("Sets the contract address", async () => {
               assert.strictEqual(auditedContract, await auditable.auditedContract());
          });

     });

     describe("# setAuditor()", () => {
          
          it("Reverts a non-auditor, non-owner call", async () => {
               const initialAuditor = await auditable.auditor();

               // message "Auditor and Owner only" is optional and it is not matched against the require statement
               truffleAssert.reverts(auditable.setAuditor(_auditor = stranger, {from: stranger}), "Auditor and Owner only");
               const sameAuditor = await auditable.auditor();
               
               assert.strictEqual(initialAuditor, sameAuditor);
          });

          it("Reverts after an approved audit", async () => {
               await auditable.approveAudit({from: auditor});

               const initialAuditor = await auditable.auditor();

               // message "Cannot change auditor post audit" is optional and it is not matched against the require 
               // statement
               truffleAssert.reverts(auditable.setAuditor(_auditor = stranger, {from: owner}), "Cannot change auditor post audit");
               const sameAuditor = await auditable.auditor();
               
               assert.strictEqual(initialAuditor, sameAuditor);
          });

          it("Changes the auditor address when owner calls", async () => {
               const initialAuditor = await auditable.auditor();

               await auditable.setAuditor(_auditor = stranger, {from: owner})
               const newAuditor = await auditable.auditor();
               
               assert.notStrictEqual(initialAuditor, stranger);
               assert.strictEqual(stranger, newAuditor);
          });

          it("Changes the auditor address when auditor calls", async () => {
               const initialAuditor = await auditable.auditor();

               await auditable.setAuditor(_auditor = stranger, {from: auditor})
               const newAuditor = await auditable.auditor();
               
               assert.notStrictEqual(initialAuditor, stranger);
               assert.strictEqual(stranger, newAuditor);
          });

          it("Emits the event SetAuditor", async () => {
               const initialAuditor = await auditable.auditor();

               const transaction = await auditable.setAuditor(_auditor = stranger, {from: auditor})

               const newAuditor = await auditable.auditor();

               assert.strictEqual("SetAuditor", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(initialAuditor, transaction.logs[0].args._previousAuditor);
               assert.strictEqual(newAuditor, transaction.logs[0].args._newAuditor);
               assert.strictEqual(auditedContract, transaction.logs[0].args._contract);
               assert.strictEqual("Auditor has been set", transaction.logs[0].args._message);

               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });

     });

     describe("# approveAudit()", () => {

          it("Reverts a non-auditor call", async () => {
               const initiallyNotAudited = await auditable.audited();

               // message "Auditor only" is optional and it is not matched against the require statement
               truffleAssert.reverts(auditable.approveAudit({from: owner}), "Auditor only");
               const afterNotAudited = await auditable.audited();
               
               assert.isFalse(initiallyNotAudited);
               assert.strictEqual(initiallyNotAudited, afterNotAudited);
          });

          it("Reverts after contract is approved", async () => {
               await auditable.approveAudit({from: auditor});

               // message "Contract has already been approved" is optional and it is not matched against 
               // the require statement
               truffleAssert.reverts(auditable.approveAudit({from: auditor}), "Contract has already been approved");
          });

          it("Emits the event ApprovedAudit", async () => {
               const initiallyNotAudited = await auditable.audited();

               const transaction = await auditable.approveAudit({from: auditor})

               const afterIsAudited = await auditable.audited();

               assert.isFalse(initiallyNotAudited);
               assert.isTrue(afterIsAudited);

               assert.strictEqual("ApprovedAudit", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(auditor, transaction.logs[0].args._auditor);
               assert.strictEqual(auditedContract, transaction.logs[0].args._contract);
               assert.strictEqual("Contract approved, functionality unlocked", transaction.logs[0].args._message);

               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });

     });

     describe("# opposeAudit()", () => {

          it("Reverts a non-auditor call", async () => {
               const initiallyNotAudited = await auditable.audited();
               
               // message "Auditor only" is optional and it is not matched against the require statement
               truffleAssert.reverts(auditable.opposeAudit({from: owner}), "Auditor only");
               const afterNotAudited = await auditable.audited();
               
               assert.isFalse(initiallyNotAudited);
               assert.strictEqual(initiallyNotAudited, afterNotAudited);
          });

          it("Emits the event OpposedAudit", async () => {
               const initiallyNotAudited = await auditable.audited();

               const transaction = await auditable.opposeAudit({from: auditor})

               const afterIsAudited = await auditable.audited();

               assert.isFalse(initiallyNotAudited);
               assert.isFalse(afterIsAudited);

               assert.strictEqual("OpposedAudit", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(auditor, transaction.logs[0].args._auditor);
               assert.strictEqual(auditedContract, transaction.logs[0].args._contract);
               assert.strictEqual("Contract has failed the audit", transaction.logs[0].args._message);

               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });

          it("Reverts after contract is approved", async () => {
               // This test has to be below "Emits the event OpposedAudit" because truffle
               // is fucking garbage and will fail it otherwise. It makes no sense.
               await auditable.opposeAudit({from: auditor});

               // message "Cannot destroy an approved contract" is optional and it is not matched against 
               // the require statement
               truffleAssert.reverts(auditable.opposeAudit({from: auditor}), "Cannot destroy an approved contract");
          });

     });
});