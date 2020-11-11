// Deploy a demo contract showing how to query Macroverse.
var MacroverseUserExample = artifacts.require("MacroverseUserExample")

// Grab the contract we depend on
var MacroverseStarGenerator = artifacts.require("MacroverseStarGenerator")

module.exports = function(deployer, network, accounts) {
  // Pass along its address to the dependent contract.
  deployer.deploy(MacroverseUserExample, MacroverseStarGenerator.address)
}

