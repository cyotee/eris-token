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
          // fake NFT addresses as regular addresses
          NFT = accounts[8];
          nextNFT = accounts[9];
     });

     beforeEach(async () => {
          donations = await Donations.new(_NFT = NFT, {from: owner});
     });

     describe("# constructor()", () => {

          it("Sets the NFT address", async () => {
               assert.strictEqual(NFT, await donations.NFT());
          });

          it("Flips the paused state to true", async () => {
               assert.isTrue(await donations.paused());
          });

     });

     describe("# donate()", () => {

          const oneETH = parseInt(web3.utils.toWei('1', 'ether'));
          
          it("Reverts when paused", async () => {
               // message "Donations are currently paused" is optional and it is not matched 
               // against the require statement
               truffleAssert.reverts(donations.donate({from: owner, value: oneETH}), "Donations are currently paused");
          });

          it.skip("Does not mint with insufficient balance but emits Donated event", async () => {
               // do not use this until there is a way to wrap the NFT.call to make sure that it is not minted...
               await donations.flipPauseState({from: owner});
               const donation = oneETH / 100;
               const transaction = await donations.donate({from: owner, value: donation});

               assert.strictEqual("Donated", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(owner, transaction.logs[0].args._donator);
               assert.strictEqual(String(donation), transaction.logs[0].args._value.toString());
               assert.strictEqual("A donation has been received", transaction.logs[0].args._message);
          });

          it.skip("Mints token and emits Donated event", async () => {
               // do not use this until there is a way to wrap the NFT.call to make sure that it is minted...
               await donations.flipPauseState({from: owner});

               const donation = oneETH / 10;
               const transaction = await donations.donate({from: owner, value: donation});

               assert.strictEqual("Donated", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(owner, transaction.logs[0].args._donator);
               assert.strictEqual(String(donation), transaction.logs[0].args._value.toString());
               assert.strictEqual("A donation has been received", transaction.logs[0].args._message);
          });
     
     });

     describe("# setNFT()", () => {

          it("Reverts a non-owner call", async () => {
               const previousNFT = await donations.NFT();
               // message "Owner only" is optional and it is not matched against the require statement
               truffleAssert.reverts(donations.setNFT(_NFT = nextNFT, {from: notOwner}), "Owner only");
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
               const initialNFT = await donations.NFT();

               const transaction = await donations.setNFT(_NFT = nextNFT)

               assert.strictEqual("ChangedNFT", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(initialNFT, transaction.logs[0].args._previous);
               assert.strictEqual(nextNFT, transaction.logs[0].args._next);
               assert.strictEqual("The NFT has been updated", transaction.logs[0].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });
     });

     describe("# destroyContract()", () => {

          it("Reverts a non-owner call", async () => {
               // message "Owner only" is optional and it is not matched against the require statement
               truffleAssert.reverts(donations.destroyContract({from: notOwner}), "Owner only");
          });

          it("Emits the event SelfDestructed", async () => {

               const transaction = await donations.destroyContract();

               assert.strictEqual("SelfDestructed", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(donations.address, transaction.logs[0].args._self);
               assert.strictEqual("Destructing the donation platform", transaction.logs[0].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[0].args._time.toNumber())
          });
     

          it.skip("Destroys the contract", async () => {
               // how do I access the selfdestruct so that I can stub it or something...
          });
     });
});