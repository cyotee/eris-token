// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "./IEventBroadcaster.sol";
import "../libraries/security/events/AuthorizationDatastoreEvents.sol";

/**
 * Intended to receive calls from other contracts in the ecosystem to emit events on their behalf.
 */
contract EventBroadcaster is IEventBroadcaster {

    /**
     * Needs inegration with authorization platform NOT AuthroizationDataStore to confirm calls are only coming from registered contracts.
     */

    function emitRoleAdminChanged( address contract_, bytes32 role_, bytes32 previousAdminRole_, bytes32 newAdminRole_ ){

    }

    function emitRoleGranted( address contract_, bytes32 role_, address grantee_, address grantor_ );

    function emitRoleRevoked( address contract_, bytes32 role_, address account_, address sender_ );

    function emitRoleApproverChanged( address contract_, bytes32 role_, bytes32 approverRole_, bytes32 newApproverRole_ );

    function emitRestrictedSharedRoleAdded( address contract_, bytes32 role_, bytes32 restrictedSharedRole_ );

    function emitNewContractRegistered( address newRegisteredContract_, bytes32 rootRole_, address rootAdminAddress_ ) {
        emit AuthorizationDatastoreEvents.NewContractRegistered( contractToRegister_,  rootRole_, newRootAddress_ );
    }
}