// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../../contracts/abstract/ERC20.sol";
import "../../contracts/libraries/utils/math/SafeMath.sol";
import "../../contracts/libraries/datatypes/primitives/Address.sol";

contract TestToken1 is ERC20 {

    using SafeMath for uint256;
    using Address for address;

    constructor () ERC20( "TestToken1", "TT1" ) {
        console.log("TestToken1::constructor: Instantiating TestToken1");
        _mint(_msgSender(), 50000 * 1**decimals()  );
        console.log("TestToken1::constructor: Instantiated TestToken1");
    }
}