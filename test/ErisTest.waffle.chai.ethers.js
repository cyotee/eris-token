const { utils } = require("ethers").utils;
const { expect } = require("chai");
const { ethers, waffle, solidity } = require("hardhat");
const { expectRevert, time, BN } = require('@openzeppelin/test-helpers');
const { deployContract } = waffle;

describe(
    "Eris contract waffle/chai/ethers test",
    function () {

        // Roles
        let DEFAULT_ADMIN_ROLE = ethers.utils.solidityKeccak256( ["string"], ["DEFAULT_ADMIN_ROLE"] );
        let MINTER_ROLE = ethers.utils.solidityKeccak256( ["string"], ["MINTER_ROLE"] );

        // let erisToEthRatio = 5;

        // let burnAddress = "0x0000000000000000000000000000000000000000";

        // Wallets
        let deployer;
        // let newOwner;
        // let charity;
        // let newCharity;
        // let newDev;
        let buyer1;
        // let buyer2;
        // let buyer3;

        // Contracts

        // let UniswapV2FactoryContract;
        // let uniswapV2Factory;

        // let UniswapV2RouterContract;
        // let uniswapV2Router;

        // let WETH9Contract;
        // let weth;

        // let erisWETHDEXPair;

        let ErisContract;
        let eris;

        beforeEach(
            async function () {
                [
                    deployer,
                    // newOwner,
                    // charity,
                    // newCharity,
                    // newDev,
                    buyer1//,
                    // buyer2,
                    // buyer3
                ] = await ethers.getSigners();

                // UniswapV2FactoryContract = await ethers.getContractFactory("UniswapV2Factory");
                // uniswapV2Factory = await UniswapV2FactoryContract
                //     .connect( owner )
                //     .deploy( owner.address );

                // WETH9Contract = await ethers.getContractFactory("WETH9")
                // weth = await WETH9Contract.connect( owner ).deploy();

                // UniswapV2RouterContract = await ethers.getContractFactory("UniswapV2Router02");
                // uniswapV2Router = await UniswapV2RouterContract.connect( owner ).deploy( uniswapV2Factory.address, weth.address );

                ErisContract = await ethers.getContractFactory("ErisToken");

                //Add check for events
                eris = await ErisContract.connect( deployer ).deploy();

                // erisWETHDEXPair = await uniswapV2Factory.connect( owner ).getPair( eris.address, weth.address);
            }
        );

        describe(
            "Deployment",
            function () {
                it( 
                    "DeploymentSuccess", 
                    async function() {
                        expect( await eris.hasRole( eris.DEFAULT_ADMIN_ROLE(), deployer.address ) ).to.equal( true );
                        console.log("Deployment::DeploymentSuccess: token name.");
                        expect( await eris.name() ).to.equal("ERIS");
                        console.log("Deployment::DeploymentSuccess: token symbol.");
                        expect( await eris.symbol() ).to.equal("ERIS");
                        console.log("Deployment::DeploymentSuccess: token decimals.");
                        expect( await eris.decimals() ).to.equal(18);
                        //console.log("Deployment::DeploymentSuccess: token burnAddress.");
                        // expect( await eris.burnAddress() ).to.equal(burnAddress);
                        console.log("Deployment::DeploymentSuccess: token totalSupply.");
                        expect( await eris.totalSupply() ).to.equal(0);
                        //console.log("Deployment::DeploymentSuccess: owner.");
                        // expect( await eris.owner() ).to.equal(owner.address);
                        //console.log("Deployment::DeploymentSuccess: devAddress.");
                        // expect( await eris.devAddress() ).to.equal(owner.address);
                        //console.log("Deployment::DeploymentSuccess: charityAddress.");
                        // expect( await eris.charityAddress() ).to.equal(charity.address);
                        //console.log("Deployment::DeploymentSuccess: qplgmeActive.");
                        // expect( await eris.qplgmeActive() ).to.equal(false);
                        expect( await eris.connect(deployer).balanceOf(deployer.address) ).to.equal( String( 0 ) );
                        expect( await eris.connect(deployer).balanceOf(buyer1.address) ).to.equal( String( 0 ) );
                        // expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
                        // expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
                        // expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
                    }
                );
            }
        );

        // describe(
        //     "Owner Management",
        //     function () {
        //         it( 
        //             "Confirm owner management.", 
        //             async function() {
        //                 expect( await eris.owner() ).to.equals(owner.address)
        //                 expect( await eris.devAddress() ).to.equals(owner.address);
        //                 expect( await eris.charityAddress() ).to.equal(charity.address);

        //                 await expect( eris.connect(newOwner).changeCharityAddress(newOwner.address) ).to.be.revertedWith("Ownable: caller is not the owner");
        //                 expect( await eris.charityAddress() ).to.equal(charity.address);
        //                 expect( await eris.connect(owner).changeCharityAddress(newCharity.address));
        //                 expect( await eris.charityAddress() ).to.equal(newCharity.address);

        //                 await expect( eris.connect(newOwner).changeDevAddress(newOwner.address) ).to.be.revertedWith("Ownable: caller is not the owner");
        //                 expect( await eris.devAddress() ).to.equal(owner.address);
        //                 expect( await eris.connect(owner).changeDevAddress(newDev.address));
        //                 expect( await eris.devAddress() ).to.equal(newDev.address);
        //             }
        //         );

        //         it(
        //             "Confirm only owner can start QPLGME",
        //             async function() {
        //                 await expect( eris.connect(newOwner).startQPLGME() ).to.be.revertedWith("Ownable: caller is not the owner");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //                 await expect( eris.connect(owner).startQPLGME() ).to.emit(eris,"QPLGMEStarted");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).totalExchangeERISReserve() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //             }
        //         );

        //         it(
        //             "Confirm only owner can end QPLGME",
        //             async function() {
        //                 await expect( eris.connect(owner).startQPLGME() ).to.emit(eris,"QPLGMEStarted");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.qplgmeActive() ).to.equal(true);
        //                 expect( await eris.hadQPLGME() ).to.equal(false);
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //                 await expect( eris.connect(newOwner).endQPLGME() ).to.be.revertedWith("Ownable: caller is not the owner");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.qplgmeActive() ).to.equal(true);
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //                 await expect( eris.connect(owner).endQPLGME() ).to.emit(eris,"QPLGMEEnded");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.qplgmeActive() ).to.equal(false);
        //                 expect( await eris.hadQPLGME() ).to.equal(false);
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).totalExchangeERISReserve() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //             }
        //         );
        //     }
        // );

        // describe(
        //     "Buy Eris.",
        //     function () {
        //         it(
        //             "Try to buy Eris.",
        //             async function() {
                        
        //                 var buy1Amount = 1;

        //                 await expect( eris.connect(owner).startQPLGME() ).to.emit(eris,"QPLGMEStarted");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.qplgmeActive() ).to.equal(true);
        //                 expect( await eris.hadQPLGME() ).to.equal(false);
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).totalExchangeERISReserve() ).to.equal( String( 0 ) );
        //                 expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
                        
        //                 expect( await eris.connect(buyer1).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
                        
        //                 expect( await eris.connect(buyer2).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 expect( await eris.connect(buyer2).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );

        //                 expect( await eris.connect(buyer3).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 expect( await eris.connect(buyer3).withdrawPaidETHForfietAllERIS() );

        //                 await expect( eris.connect(owner).endQPLGME() ).to.emit(eris, "QPLGMEEnded");
                        
        //                 expect( await weth.balanceOf(charity.address)).to.equal( String( 0 ) );

        //                 await expect( eris.connect(buyer1).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer1).balanceOf(buyer1.address) ).to.equal( String( 7071067810000000000 ) );
        //                 expect( await weth.balanceOf(charity.address)).to.equal( String( 300000000000000000 ) );

        //                 await expect( eris.connect(buyer2).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer2).balanceOf(buyer2.address) ).to.equal( String( 10000000000000000000 ) );

        //                 await expect( eris.connect(buyer1).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer1).balanceOf(buyer1.address) ).to.equal( String( 7071067810000000000 ) );
                        
        //                 await expect( eris.connect(buyer3).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer3).balanceOf(buyer3.address) ).to.equal( String( 0 ) );

        //             }
        //         );
        //     }
        // );

        // describe(
        //     "Complete QPLGME.",
        //     function () {
        //         it(
        //             "Try to transfer Eris.",
        //             async function() {
                        
        //                 var buy1Amount = 750;

        //                 //console.log( "Starting QPLGME.");
        //                 await expect( eris.connect(owner).startQPLGME() ).to.emit(eris,"QPLGMEStarted").withArgs( await eris.qplgmeActive(), await eris.qplgmeStartTimestamp());
        //                 //console.log("Confirming QPLGME is active.");
        //                 expect( await eris.qplgmeActive() ).to.equal(true);
        //                 //console.log("Confirming ERIS totalsupply.");
        //                 expect( await eris.totalSupply() ).to.equal( String( 0 ) );
                        
        //                 //console.log("Buying Eris.");
        //                 expect( await eris.connect(buyer1).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 // expect( ethers.utils.parseUnits( String( await  buyer1.getBalance() ), "gwei" ) ).to.equal( ethers.utils.parseUnits( String( 9998997990712000000000 ), "gwei" ) );
                        
        //                 expect( await eris.connect(buyer2).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 // expect( await buyer1.getBalance() ).to.equal( String( 9998997990712000000000 ) );
        //                 // expect( await eris.connect(buyer2).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 // expect( await buyer1.getBalance() ).to.equal( String( 9998997990712000000000 ) );

        //                 expect( await eris.connect(buyer3).buyERIS( { value: ethers.utils.parseEther( String( buy1Amount ) ) } ) );
        //                 // expect( await buyer1.getBalance() ).to.equal( String( 9998997990712000000000 ) );
        //                 expect( await eris.connect(buyer3).withdrawPaidETHForfietAllERIS() );
        //                 // expect( await buyer1.getBalance() ).to.equal( String( 1000000000000000000000 ) );

        //                 await expect( eris.connect(owner).endQPLGME() ).to.emit(eris, "QPLGMEEnded");
                        
        //                 expect( await weth.balanceOf(charity.address)).to.equal( String( 0 ) );

        //                 await expect( eris.connect(buyer1).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer1).balanceOf(buyer1.address) )
        //                     //.to.equal( String( 7071067810000000000 ) )
        //                     ;
        //                 // expect( await eris.totalSupply() ).to.equal( String( 1676392616930000000000 ) );
        //                 // expect( await eris.connect(owner).balanceOf(owner.address) ).to.equal( String( 0 ) );
        //                 // expect( await eris.connect(owner).balanceOf(charity.address) ).to.equal( String( 0 ) );
        //                 // expect( await eris.connect(owner).balanceOf( eris.uniswapV2ErisWETHDEXPairAddress() ) ).to.equal( String( 0 ) );
        //                 // expect( await eris.connect(owner).totalExchangeERISReserve() ).to.equal( String( 0 ) );
        //                 // expect( await eris.connect(owner).balanceOf( eris.address ) ).to.equal( String( 0 ) );
        //                 expect( await weth.balanceOf(charity.address))
        //                     //.to.equal( String( 300000000000000000 ) )
        //                     // ;

        //                 await expect( eris.connect(buyer2).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer2).balanceOf(buyer2.address) )
        //                     //.to.equal( String( 10000000000000000000 ) )
        //                     ;

        //                 await expect( eris.connect(buyer1).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer1).balanceOf(buyer1.address) )
        //                     //.to.equal( String( 7071067810000000000 ) )
        //                     ;
                        
        //                 await expect( eris.connect(buyer3).collectErisFromQPLGME() );
        //                 expect( await eris.connect(buyer3).balanceOf(buyer3.address) )
        //                     //.to.equal( String( 0 ) )
        //                     ;

        //                 //console.log("Confirming buyer1 can transfer %s.", ethers.utils.parseUnits( String( 217944947175000000000 ), "wei" ) );
        //                 await expect( eris.connect(buyer1).transfer(buyer2.address, 217944947175000000000) );
        //                 // expect( await eris.connect(buyer1).balanceOf(buyer1.address) ).to.equal( String( 0 ) );
        //                 // expect( await eris.connect(buyer2).balanceOf(buyer2.address) ).to.equal( String( 437160310264880370000 ) );
        //                 // expect( await eris.connect(buyer1).balanceOf(eris.address) ).to.equal( String( 0 ) );

                        
        //             }
        //         );
        //     }
        // );
    }
);