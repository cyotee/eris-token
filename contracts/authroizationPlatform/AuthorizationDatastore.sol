// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../dependencies/libraires/datatypes/security/structs/RoleData.sol";
import "../dependencies/libraires/datatypes/security/events/AuthorizationDatastoreEvents.sol";
import "../eventBroadcaster/interfaces/IEventBroadcaster.sol";

 /**
  * Conract to store the role authorization data for the rest of the platform.
  * Should be expecting calls from the AuthorizationPlatform and return bools or bytes32 for evaluation results.
  */
contract AuthorizationDatastore {

    using RoleData for RoleData.RoleData;
    using RoleData for RoleData.ContractRoles;

    address private _authorizationPlatform;

    IEventBroadcaster private _eventBroadcaster;

    modifier onlyPlatform() {
        require( _msgSender() == authorizationPlatform );
        _;
    }

    mapping( address => RoleData.ContractRoles ) private _contractRoles;

    // TODO Needs integration to register itself for authorization so event boradcaster and authoirzation platform addresaes can be updated
    constructor( address ) {
        console.log( "Instantiating AuthorizationDatastore." );
        console.log( "Instantiated AuthorizationDatastore." );
    }

    // TODO: Better name to indicate that I'm getting an address type of the broadcaster
    function eventBroadcaster() public view returns ( address ) {
        return address( _eventBroadcaster );
    }

    // TODO needs to confirm registered contracts are actuall contracts.
    function registerContract( address contractToRegister_, bytes32 rootRole_, address newRootAddress_ ) public onlyPlatform() {
        _eventBroadcaster.emitNewContractRegistered( address contractToRegister_d, bytes32 rootRole_, address rootAdminAddress_ );
        _contractRoles[contractToRegister_].roles[adminRole_].roleApproval[newRootAddress_] = true;
        _contractRoles[contractToRegister_].roles[adminRole_].members.add(newRootAddress_);
        _contractRoles[contractToRegister_].rootRole = rootRole_;
        _contractRoles[contractToRegister_].roles[rootRole_].adminRole = rootRole_;
    }

    function setupRole( address contract_, address submitter_, bytes32 role_, bytes32 adminRole_, bytes32 approverRole_ ) public onlyPlatform() {
        require( _contractRoles[contract_].roles[_contractRoles[contract_].rootRole].members.contains(submitter_) );
        _setRoleAdmin( contract_, submitter_, role_, adminRole_ );
        _setApproverRole( contract_, role_, approverRole_ );
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin( address contract_, address submitter_, bytes32 role_, bytes32 adminRole_ ) internal virtual {
        emit AuthorizationDatastoreEvents.RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _contractRoles[contract_].roles[role_].adminRole = adminRole_;
    }

    function _setApproverRole( address contract_, address submitter, bytes32 role_, bytes32 approverRole_ ) internal virtual {
        emit AuthorizationDatastoreEvents.RoleAdpproverChanged( role, _roles[role].approverRole, newApproverRole);
        _contractRoles[contract_].roles[role_].approverRole = approverRole_;
    }

    function addRestrictedSharedRoles( address contract_, address submitter, bytes32 role, bytes32 restrictedSharedRole ) public onlyPlatform() {
        require( _contractRoles[contract_].roles[_contractRoles[contract_].rootRole].members.contains(submitter_) );
    }

    function _addRestrictedSharedRoles( address contract_, address submitter_, bytes32 role_, bytes32 restrictedSharedRole_ ) internal virtual {
        emit AuthorizationDatastoreEvents.RestrictedSharedRoleAdded( contract_, role_, restrictedSharedRole_ );
        _contractRoles[contract_].roles[role].restrictedSharedRoles.add( restrictedSharedRole );
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole( address contract, bytes32 role, address account ) public onlyPlatform() {
        console.log("RoleBasedAccessControl::grantRole checking that %s is approved to have role.", account );
        
        require( _isApproveForRole( role, account ), "RoleBasedAccessControl::grantRole Address is not approved for role." );
        console.log("RoleBasedAccessControl::grantRole checking that %s is admin to set role.", Context._msgSender());
        
        require(hasRole(_roles[role].adminRole, Context._msgSender()), "RoleBasedAccessControl: sender must be an admin to grant");
        console.log("RoleBasedAccessControl::grantRole checking that %s does not have any restricted shared roles for role.", account);
        
        require( !hasRestrictedSharedRole( role, account ), "RoleBasedAccessControl::grantRole account has restrictedSharedRoles with role." );
        console.log("RoleBasedAccessControl::grantRole Granting %s role.", account);
        
        _grantRole( contract role, account);
        console.log("RoleBasedAccessControl::grantRole Granted %s role.", account);
    }

    function _grantRole( address contract, bytes32 role, address account) private {
        console.log("RoleBasedAccessControl: Granting %s role.", account);
        if (_roles[role].members.add(account)) {
            emit AuthorizationDatastoreEvents.RoleGranted(role, account, Context._msgSender());
        }
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function hasRestrictedSharedRole( bytes32 role, address challenger ) public view returns ( bool ) {

        for( uint8 iteration = 0; iteration < _roles[role].restrictedSharedRoles.length(); iteration++ ){
            if( _roles[_roles[role].restrictedSharedRoles.at( iteration )].members.contains( challenger ) ) {
                return _roles[_roles[role].restrictedSharedRoles.at( iteration )].members.contains( challenger );
            }
        }

        return false;
    }

    function hasAnyOfRoles( bytes32[] storage roles_, address challenger ) internal view returns ( bool ) {

        for( uint8 iteration = 0; iteration <= roles_.length; iteration++ ){
            if( hasRole( roles_[iteration], challenger ) ){
                return hasRole( roles_[iteration], challenger );
            }
        }

        return false;
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length;
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function isApprovedForRole( bytes32 role, address queryAddress ) public view returns ( bool ) {
        return _isApproveForRole( role, queryAddress );
    }

    function approveForRole( bytes32 role, address approvedAccount ) public virtual {
        require( hasRole( _roles[role].approverRole, Context._msgSender() ), "RoleBasedAccessControl::approveForRole caller is not role approver." );
        _approveForRole( role, approvedAccount );
    }

    function revokeApproval( bytes32 role, address disapprovedAccount ) public virtual {
        require( hasRole( _roles[role].approverRole, Context._msgSender() ), "RoleBasedAccessControl::approveForRole caller is not role approver." );
        _revokeRoleApproval( role, disapprovedAccount );
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, Context._msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == Context._msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, Context._msgSender());
        }
    }

    function _approveForRole(bytes32 role, address approvedAccount) internal {
        emit RoleApproved( role, Context._msgSender(), approvedAccount );
        _roles[role].roleApproval[approvedAccount] = true;
    }

    function _revokeRoleApproval( bytes32 role, address revokedAccount ) internal {
        emit ApprovalRevoked( role, Context._msgSender(), revokedAccount );
        _roles[role].roleApproval[revokedAccount] = false;
    }

    function _isApproveForRole( bytes32 role, address queryAddress ) internal view returns ( bool ) {
        return _roles[role].roleApproval[queryAddress];
    }

}