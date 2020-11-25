const Ownable = artifacts.require("Ownable");
const truffleAssert = require("truffle-assertions");

contract("Ownable", async (accounts) => {

     let owner;
     let currentlyNotOwner;
     let ownable;

     before(() => {
          owner = accounts[0];
          currentlyNotOwner = accounts[1];
     });

     beforeEach(async () => {
          ownable = await Ownable.new({from: owner});
     });

     describe("# constructor()", () => {

          it("Sets the owner address", async () => {
               assert.strictEqual(owner, await ownable.owner());
          });

     });

     describe("# transferOwnership()", () => {

          it("Reverts a non-owner call", async () => {
               const currentOwner = await ownable.owner();

               // message "Owner only" is optional and it is not matched against the require statement
               truffleAssert.reverts(ownable.transferOwnership(_owner = currentlyNotOwner, {from: currentlyNotOwner}), "Owner only");

               const sameOwner = await ownable.owner();

               assert.strictEqual(currentOwner, owner);
               assert.notStrictEqual(currentOwner, currentlyNotOwner);
               assert.strictEqual(sameOwner, owner);
          });

          it("Changes the owner address", async () => {
               const initialOwner = await ownable.owner();

               await ownable.transferOwnership(_owner = currentlyNotOwner, {from: initialOwner});

               const newOwner = await ownable.owner();

               assert.strictEqual(initialOwner, owner);
               assert.notStrictEqual(initialOwner, currentlyNotOwner);
               assert.strictEqual(newOwner, currentlyNotOwner);
          });

          it("Emits the event TransferredOwnership", async () => {
               const initialOwner = await ownable.owner();
               const transaction = await ownable.transferOwnership(_owner = currentlyNotOwner, {from: initialOwner});
               const newOwner = await ownable.owner();

               assert.strictEqual("TransferredOwnership", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(initialOwner, transaction.logs[0].args._previous);
               assert.strictEqual(newOwner, transaction.logs[0].args._next);
               assert.strictEqual("Ownership has been transferred", transaction.logs[0].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });
     });
});