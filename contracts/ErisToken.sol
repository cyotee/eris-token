// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "./abstract/Divine.sol";
// import "./libraries/utils/math/SafeMath.sol";
// import "./libraries/datatypes/primitives/Address.sol";
// import "../libraries/datatypes/collections/EnumerableSet.sol";

contract ErisToken is Divine {

    // using SafeMath for uint256;
    // using Address for address;
    // using EnumerableSet for EnumerableSet.AddressSet;

    constructor () Divine() {
        console.log("ERIS::constructor: Instantiating ERIS");
        // _mint(_msgSender(), 50000 * 1**decimals()  );
        console.log("ERIS::constructor: Instantiated ERIS");
    }
}