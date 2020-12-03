const Dawning_Chain = artifacts.require("Dawning_Chain");
const truffleAssert = require("truffle-assertions");

contract("Dawning_Chain", async (accounts) => {

     let owner;
     let notOwner;
     let token;

     before(() => {
          owner = accounts[0];
          notOwner = accounts[1];
     });

     beforeEach(async () => {
          token = await Dawning_Chain.new({from: owner});
     });

     describe("# mint()", () => {

          const oneETH = parseInt(web3.utils.toWei('1', 'ether'));

          it("Reverts a non-owner call", () => {
               truffleAssert.reverts(token.mint(_donator = notOwner, {from: notOwner, value: oneETH}), "Owner only")
          });

          it("Increases token ID by 1", async () => {
               const initialID = await token.tokenID();
               await token.mint(_donator = notOwner, {from: owner, value: oneETH});

               const newID = await token.tokenID();

               assert.strictEqual(0, initialID.toNumber());
               assert.strictEqual(1, newID.toNumber());
          });

          it("Keeps track of the donators", async () => {
               const notDonated = await token.donators(notOwner);

               await token.mint(_donator = notOwner, {from: owner, value: oneETH});

               const donated = await token.donators(notOwner);

               assert.isFalse(notDonated);
               assert.isTrue(donated);
          });

          it("Emits the event MintedToken", async () => {
               const transaction = await token.mint(_donator = notOwner, {from: owner, value: oneETH});

               assert.strictEqual("MintedToken", transaction.logs[1].event);
               assert.strictEqual(2, transaction.logs.length);
               assert.strictEqual(notOwner, transaction.logs[1].args._donator);
               assert.strictEqual(0, transaction.logs[1].args._tokenId.toNumber());
               assert.strictEqual("Token has been minted", transaction.logs[1].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[1].args._time.toNumber())
          });

          it("Does not mint more than once for the same donator", async () => {
               const notDonated = await token.donators(notOwner);
               
               await token.mint(_donator = notOwner, {from: owner, value: oneETH});

               const donated = await token.donators(notOwner);
               const initialID = await token.tokenID();

               await token.mint(_donator = notOwner, {from: owner, value: oneETH});

               const sameID = await token.tokenID();

               assert.isFalse(notDonated);
               assert.isTrue(donated);

               assert.strictEqual(1, initialID.toNumber());
               assert.strictEqual(1, sameID.toNumber());
          });

     });

     describe.skip("# updateMetaData()", () => {
          // error complains about not using a real token address or something

          it("Emits the event UpdatedMetaData", async () => {
               await token.mint(_donator = notOwner, {from: owner, value: parseInt(web3.utils.toWei('1', 'ether'))});
               const metaData = '{ "name": "Donations Coin", "description": "Thank you for donating!", "image": "https://ipfs.io://ipfs/QmSZUL7Ea21osUUUESX6nPuUSSTF6RniyoJGBaa2ZY7Vjd" }';
               const tokenID = 1;
               const transaction = await token.updateMetadata(_tokenID = tokenID, _metaData = metaData, {from: owner});

               assert.strictEqual("UpdatedMetaData", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(tokenID, transaction.logs[0].args._tokenId.toNumber());
               assert.strictEqual("Updated token metadata", transaction.logs[0].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[1].args._time.toNumber())
          });

     });

     describe.skip("# _transfer()", () => {
          // how to test internal functions?

          it("Emits the event TransferAttempted", async () => {
               const tokenID = 1;
               const transaction = await token._transfer(from = owner, to = notOwner, _tokenID = tokenID);

               assert.strictEqual("TransferAttempted", transaction.logs[0].event);
               assert.strictEqual(1, transaction.logs.length);
               assert.strictEqual(owner, transaction.logs[0].args.from);
               assert.strictEqual(notOwner, transaction.logs[0].args.to);
               assert.strictEqual(tokenID, transaction.logs[0].args._tokenId.toNumber());
               assert.strictEqual("The NFT is a non-fungible, non-transferable token", transaction.logs[0].args._message);
               
               // how do I mock the "now" call and test that?
               // console.log(transaction.logs[1].args._time.toNumber())
          });

     });
});