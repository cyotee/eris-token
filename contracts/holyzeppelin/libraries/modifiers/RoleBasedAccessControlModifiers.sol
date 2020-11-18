/**
Library to ldefine reusable AuthorizationPlatfomr integration modifiers.
 */
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

library RoleBasedAccessControlModifiers {

    modifier onlyRole( bytes32 role_ ) {
        require( hasRole( role_, Context._msgSender() ), "RoleBasedAccessControl: account for not has authroized role for action." );
        _;
    }
    
}