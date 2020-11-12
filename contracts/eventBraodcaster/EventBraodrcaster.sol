// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "./IEventBroadcaster.sol";
import "../dependencies/libraries/security/events/AuthorizationDatastoreEvents.sol";

/**
 * Intended to receive calls from other contracts in the ecosystem to emit events on their behalf.
 */

/**
* Needs inegration with authorization platform NOT AuthroizationDataStore to confirm calls are only coming from registered contracts.
*/

contract EventBroadcaster is IEventBroadcaster {

    function roleAdminChanged( address contract_, bytes32 role_, bytes32 previousAdminRole_, bytes32 newAdminRole_ ) {
        emit AuthorizationDatastoreEvents.RoleAdminChanged( contract_, role_, previousAdminRole_, newAdminRole_ );
    }

    function roleGranted( address contract_, bytes32 role_, address grantee_, address grantor_ ) {
        emit AuthorizationDatastoreEvents.RoleGranted( contract_, role_, grantee_, grantor_) ;
    }

    function roleRevoked( address contract_, bytes32 role_, address account_, address sender_ ) {
        emit AuthorizationDatastoreEvents.RoleRevoked( contract_, role_, account_, sender_ );
    }

    function roleApproverChanged( address contract_, bytes32 role_, bytes32 approverRole_, bytes32 newApproverRole_ ) {
        emit AuthorizationDatastoreEvents.RoleApproverChanged( contract_, role_, approverRole_, newApproverRole_ );
    }

    function restrictedSharedRoleAdded( address contract_, bytes32 role_, bytes32 restrictedSharedRole_ ) {
        emit AuthorizationDatastoreEvents.RestrictedSharedRoleAdded( contract_, role_, restrictedSharedRole_ );
    }

    function newContractRegistered( address newRegisteredContract_, bytes32 rootRole_, address rootAdminAddress_ ) {
        emit AuthorizationDatastoreEvents.NewContractRegistered( newRegisteredContract_,  rootRole_, rootAdminAddress_ );
    }

}