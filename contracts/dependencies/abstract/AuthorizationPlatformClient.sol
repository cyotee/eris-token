// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

/**
 * Intended to store the data needed to integrate with the Authroization plaftorm contract.
 * Should reuse the RoleBasedAccessControlEvents.
 */
abstract contract AuthorizationPlatformClient {

    // Should be an interface for the AuthorizationPlatform.
    IAuthorizationPlatform private _authorizationPlatform;

    modifier hasOnlyRole( bytes32 role_, address account_ ) {
        require( _authorizationPlatform.hasRole( address(this), account_ ) );
        _;
    }

}