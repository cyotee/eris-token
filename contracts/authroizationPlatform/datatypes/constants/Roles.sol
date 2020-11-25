// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

/**
 * Encapsulation of reusable roles.
 */
library Roles {
    // Roles stored as KECCAK256 encoded byte32 to save space and to provide a bit of obfucation of values.
    // bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 internal constant ROOT_ROLE = keccak256( "ROOT_ROLE" );
    bytes32 internal constant PLATFORM_ADMIN_ROLE  = keccak256( "PLATFORM_ADMIN_ROLE" );
    bytes32 internal constant PLATFORM_ADMIN_OVERSIGHT_ROLE = keccak256( "PLATFORM_ADMIN_OVERSIGHT_ROLE" );
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
}