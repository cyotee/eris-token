const { utils } = require("ethers").utils;
const { expect } = require("chai");
const { ethers, waffle, solidity } = require("hardhat");
const { expectRevert, time, BN } = require('@openzeppelin/test-helpers');
const { deployContract } = waffle;
// const provider = waffle.provider;

describe(
    "TestToken2 Test",
    function() {

        let deployer;
        let tokenreceiver;

        let TT2Contract;
        let tt2;

        beforeEach(
            async function () {
                [
                    deployer,
                    tokenreceiver
                ] = await ethers.getSigners();

                TT2Contract = await ethers.getContractFactory("TestToken2");
                tt2 = await TT2Contract.connect(deployer).deploy();
            }
        );

        describe(
            "Deployment",
            function () {
                it( 
                    "DeploymentSuccess", 
                    async function() {
                        console.log("Deployment::DeploymentSuccess: token name.");
                        expect( await tt2.name() ).to.equal("TestToken2");
                        console.log("Deployment::DeploymentSuccess: token symbol.");
                        expect( await tt2.symbol() ).to.equal("TT2");
                        console.log("Deployment::DeploymentSuccess: token decimals.");
                        expect( await tt2.decimals() ).to.equal(18);
                        console.log("Deployment::DeploymentSuccess: token totalSupply.");
                        expect( await tt2.totalSupply() ).to.equal(50000);
                        expect( await tt2.connect(deployer).balanceOf(deployer.address) ).to.equal( String( 50000 ) );
                    }
                );
            }
        );

        describe(
            "Test ERC20 function",
            function () {
                it(
                    "Test token transfer",
                    async function () {
                        await expect( tt2.connect(deployer).transfer( tokenreceiver.address, 10000 ) );
                        expect( await tt2.connect(deployer).balanceOf( deployer.address ) ).to.equal( String( 40000 ) );
                        expect( await tt2.connect(tokenreceiver).balanceOf( tokenreceiver.address ) ).to.equal( String( 10000 ) );
                    }
                );
            }
        );
    }
);