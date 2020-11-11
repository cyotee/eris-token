const { utils } = require("ethers").utils;
const { expect } = require("chai");
const { ethers, waffle, solidity } = require("hardhat");
const { expectRevert, time, BN } = require('@openzeppelin/test-helpers');
const { deployContract } = waffle;
// const provider = waffle.provider;

describe(
    "TestToken1 Waffle/Chai/Ethers Test",
    function() {

        let deployer;
        let tokenreceiver;

        let TT1Contract;
        let tt1;

        beforeEach(
            async function () {
                [
                    deployer,
                    tokenreceiver
                ] = await ethers.getSigners();

                TT1Contract = await ethers.getContractFactory("TestToken1");
                tt1 = await TT1Contract.connect(deployer).deploy();
            }
        );

        describe(
            "Deployment",
            function () {
                it( 
                    "DeploymentSuccess", 
                    async function() {
                        console.log("Deployment::DeploymentSuccess: token name.");
                        expect( await tt1.name() ).to.equal("TestToken1");
                        console.log("Deployment::DeploymentSuccess: token symbol.");
                        expect( await tt1.symbol() ).to.equal("TT1");
                        console.log("Deployment::DeploymentSuccess: token decimals.");
                        expect( await tt1.decimals() ).to.equal(18);
                        console.log("Deployment::DeploymentSuccess: token totalSupply.");
                        expect( await tt1.totalSupply() ).to.equal(50000);
                        expect( await tt1.connect(deployer).balanceOf(deployer.address) ).to.equal( String( 50000 ) );
                    }
                );
            }
        );

        describe(
            "Test ERC20 function",
            function () {
                it(
                    "Test toekn transfer",
                    async function () {
                        await expect( tt1.connect(deployer).transfer( tokenreceiver.address, 10000 ) );
                        expect( await tt1.connect(deployer).balanceOf( deployer.address ) ).to.equal( String( 40000 ) );
                        expect( await tt1.connect(tokenreceiver).balanceOf( tokenreceiver.address ) ).to.equal( String( 10000 ) );
                    }
                );
            }
        );
    }
);