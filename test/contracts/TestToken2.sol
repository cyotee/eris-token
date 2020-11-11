// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../../contracts/abstract/ERC20.sol";
import "../../contracts/libraries/utils/math/SafeMath.sol";
import "../../contracts/libraries/datatypes/primitives/Address.sol";

contract TestToken2 is ERC20 {

    constructor () ERC20( "TestToken2", "TT2" ) {
        console.log("TestToken2::constructor: Instantiating TestToken2");
        _mint(_msgSender(), 50000 * 1**decimals()  );
        console.log("TestToken2::constructor: Instantiated TestToken2");
    }
}