// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../../utils/math/SafeMath.sol";

/**
 * @dev Bytes32 operations.
 */
library Bytes32 {

    using SafeMath for uint256;
    
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    // function toString(uint256 value) internal pure returns (string memory) {
    //     // Inspired by OraclizeAPI's implementation - MIT licence
    //     // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    //     if (value == 0) {
    //         return "0";
    //     }
    //     uint256 temp = value;
    //     uint256 digits;
    //     while (temp != 0) {
    //         digits++;
    //         temp /= 10;
    //     }
    //     bytes memory buffer = new bytes(digits);
    //     uint256 index = digits - 1;
    //     temp = value;
    //     while (temp != 0) {
    //         buffer[index--] = byte(uint8(48 + temp % 10));
    //         temp /= 10;
    //     }
    //     return string(buffer);
    // }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
