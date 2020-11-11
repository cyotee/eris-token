pragma solidity ^0.4.19;

import "macroverse/contracts/MacroverseStarGenerator.sol";

/**
 * This example contract demonstrates querying the Macroverse Star Generator for world data.
 */

contract MacroverseUserExample {

    MacroverseStarGenerator generator;

    /**
     * Create a new instance of the example contract.
     */
    function MacroverseUserExample(address originalGenerator) {
        // On construction, save the address of the Macroverse Star Generator to query.
        generator = MacroverseStarGenerator(originalGenerator);
    }

    /**
     * Query the generator to find out if the first star in the given sector has planets.
     */
    function hasPlanetsOnFirstStar(int16 sectorX, int16 sectorY, int16 sectorZ) public view returns (bool) {
        var count = generator.getSectorObjectCount(sectorX, sectorY, sectorZ);
        if (count < 1) {
            // No first object exists
            return false;
        }

        // Get the seed for the first star
        var seed = generator.getSectorObjectSeed(sectorX, sectorY, sectorZ, 0);

        // Get the class of the object (main sequence, black hole, etc.)
        var objectClass = generator.getObjectClass(seed);

        // And get the spectral type
        var spectralType = generator.getObjectSpectralType(seed, objectClass);

        // Using all that, find out if the star even has planets, and return that.
        return generator.getObjectHasPlanets(seed, objectClass, spectralType);
    }

}

