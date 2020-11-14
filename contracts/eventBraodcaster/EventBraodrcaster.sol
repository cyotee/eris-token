// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "./IEventBroadcaster.sol";
import "../dependencies/libraries/security/events/AuthorizationDatastoreEvents.sol";

/**
 * Intended to receive calls from other contracts in the ecosystem to emit events on their behalf.
 */

contract EventBroadcaster is IEventBroadcaster {

    function roleAdminChanged( address contract_, address submitter_, bytes32 role_, bytes32 previousAdminRole_, bytes32 newAdminRole_ ) external {
        emit AuthorizationDatastoreEvents.RoleAdminChanged( contract_, submitter_, role_, previousAdminRole_, newAdminRole_ );
    }

    function roleGranted( address contract_, bytes32 role_, address grantee_, address grantor_ ) external {
        emit AuthorizationDatastoreEvents.RoleGranted( contract_, role_, grantee_, grantor_) ;
    }

    function roleRevoked( address contract_, bytes32 role_, address account_, address sender_ ) external {
        emit AuthorizationDatastoreEvents.RoleRevoked( contract_, role_, account_, sender_ );
    }

    function roleRemoved( address contract_, bytes32 role_, address account_, address sender_ ) external {
        emit AuthorizationDatastoreEvents.RoleRemoved( contract_, role_, account_, sender_ );
    }

    function roleApproverChanged( address contract_, address submitter_, bytes32 role_, bytes32 approverRole_, bytes32 newApproverRole_ ) external {
        emit AuthorizationDatastoreEvents.RoleApproverChanged( contract_, submitter_, role_, approverRole_, newApproverRole_ );
    }

    function restrictedSharedRoleAdded( address contract_, address submitter_, bytes32 role_, bytes32 restrictedSharedRole_ ) external {
        emit AuthorizationDatastoreEvents.RestrictedSharedRoleAdded( contract_, submitter_, role_, restrictedSharedRole_ );
    }

    function newContractRegistered( address newRegisteredContract_, bytes32 rootRole_, address rootAdminAddress_ ) external {
        emit AuthorizationDatastoreEvents.NewContractRegistered( newRegisteredContract_,  rootRole_, rootAdminAddress_ );
    }

    function createdRole( address contract_, address submitter_, bytes32 role_ ) external {
        emit AuthorizationDatastoreEvents.CreatedRole( contract_,  submitter_, role_ );
    }

}