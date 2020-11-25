const Donations = artifacts.require("Donations");
const truffleAssert = require("truffle-assertions");

contract("Donations", async (accounts) => {

     let owner;
     let notOwner;
     let donations;
     let NFT;
     let nextNFT;

     before(async () => {
          owner = accounts[0];
          notOwner = accounts[1];
          NFT = accounts[2];
          nextNFT = accounts[3];
     });

     beforeEach(async () => {
          donations = await Donations.new(_NFT = NFT, {from: owner});
     });

     describe("# constructor()", () => {

          it("Sets the NFT address", async () => {
               assert.strictEqual(NFT, await donations.NFT());
          });

     });

     describe("# donate()", () => {

          // This needs two more tests for when they donate more than  or equal to 0.1 ether or less than 0.1
          // and that transfer has been called
          // they are internal to the compiler/solidity and idk how to get at them for it to mock properly 

          const oneETH = parseInt(web3.utils.toWei('1', 'ether'));
          
          it("Reverts when paused", async () => {
               await donations.pause({from: owner});
               truffleAssert.reverts(donations.donate({from: owner, value: oneETH}));
          });

          it("Emits the event Donated", async () => {
               const transaction = await donations.donate({from: owner, value: oneETH});

               assert.strictEqual("Donated", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(owner, transaction.logs[0].args._donator);
               assert.strictEqual(String(oneETH), transaction.logs[0].args._value.toString());
          });
     
     });

     describe("# setNFT()", () => {

          it("Reverts a non-owner call", async () => {
               const previousNFT = await donations.NFT();
               truffleAssert.reverts(donations.setNFT(_NFT = nextNFT, {from: notOwner}));
               const newNFT = await donations.NFT();
               
               assert.strictEqual(previousNFT, newNFT);
          });

          it("Changes the NFT address", async () => {
               const initialNFT = await donations.NFT();
               
               await donations.setNFT(_NFT = nextNFT);

               const newNFT = await donations.NFT();

               assert.notStrictEqual(initialNFT, nextNFT);
               assert.strictEqual(nextNFT, newNFT);
          });

          it("Emits the event ChangedNFT", async () => {
               const transaction = await donations.setNFT(_NFT = nextNFT)

               assert.strictEqual("ChangedNFT", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(nextNFT, transaction.logs[0].args._NFT);
          });
     });

     describe("# destroyContract()", () => {

          it("Reverts a non-owner call", async () => {
               truffleAssert.reverts(donations.destroyContract({from: notOwner}));
          });

          it("Emits the event SelfDestructed", async () => {
               const transaction = await donations.destroyContract();

               assert.strictEqual("SelfDestructed", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(donations.address, transaction.logs[0].args._self);
          });

     });
});