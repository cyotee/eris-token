// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

library ERISRoles {
    // Roles stored as KECCAK256 encoded byte32 to save space and to provide a bit of obfucation of values.
    bytes32 internal constant TRADER_ROLE = keccak256( "TRADER_ROLE" );
}