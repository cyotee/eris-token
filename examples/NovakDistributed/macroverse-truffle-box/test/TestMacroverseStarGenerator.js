// If Truffle has no tests, `truffle test` just hangs

let MacroverseStarGenerator = artifacts.require("MacroverseStarGenerator");

// Load the Macroverse module JavaScript
let mv = require('macroverse/src')

contract('MacroverseStarGenerator', function(accounts) {
  it("should let us read the density", async function() {
    let instance = await MacroverseStarGenerator.deployed()
    let density = mv.fromReal(await instance.getGalaxyDensity.call(0, 0, 0))
    
    assert.isAbove(density, 0.899999, "Density at the center of the galaxy is not too small")
    assert.isBelow(density, 0.900001, "Density at the center of the galaxy is not too big")
  })
})
