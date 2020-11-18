// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

library ERC20BurnableEvents {
    // Event that alerts users of the address being set.
    event BurnAddressSet( address indexed previousBurnAddress, address indexed newBurnAddress );

    event TokenBurned( uint256 amountBurned, address burnAddress);
}