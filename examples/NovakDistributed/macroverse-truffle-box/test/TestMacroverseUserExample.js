// Make sure that the example contract to query planet presence works
let MacroverseUserExample = artifacts.require("MacroverseUserExample");

contract('MacroverseUserExample', function(accounts) {
  it("should know if the first object in a sector has planets or not", async function() {
    let instance = await MacroverseUserExample.deployed()
    
    assert.equal((await instance.hasPlanetsOnFirstStar.call(3, 1, 337)), true, "We see planets where we should")
    assert.equal((await instance.hasPlanetsOnFirstStar.call(54, 32, 1)), false, "We see no where we shouldn't")
  })
})
