// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";
import "../dependencies/libraires/security/structs/RoleData.sol";

 /**
  * Conract to store the role authorization data for the rest of the platform.
  * Should be expecting calls from the AuthorizationPlatform and return bools or bytes32 for evaluation results.
  */
contract AuthorizationDatastore {

    using RoleData for RoleData.Role;
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
    function registerContract( address contract_, bytes32 rootRole_, address newRootAddress_ ) public onlyPlatform() {
        _contractRoles[contract_].root = rootRole_;
        _contractRoles[contract_].roles[rootRole_].admin = rootRole_;
        _contractRoles[contract_].roles[rootRole_].members.add(newRootAddress_);
        _contractRoles[contract_].roles[rootRole_].approved[newRootAddress_] = true;
    }

    function setupRole( address contract_, address submitter_, bytes32 role_, bytes32 adminRole_, bytes32 approverRole_ ) public onlyPlatform() {
        RoleData.ContractRoles _contract = _contractRoles[contract_];
        require( _contract.roles[_contract.root].members.contains( submitter_ ) );

        _setRoleAdmin( contract_, submitter_, role_, adminRole_ );
        _setApproverRole( contract_, role_, approverRole_ );
    }

    function addRestrictedSharedRoles( address contract_, address submitter_, bytes32 role_, bytes32 restrictedSharedRole_ ) public onlyPlatform() {
        require( _contractRoles[contract_].roles[_contractRoles[contract_].root].members.contains( submitter_ ) );
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole( address contract_, bytes32 role_, address account_ ) external view returns ( bool ) {
        return _hasRole( contract_, role_, account_ );
    }

    function hasRestrictedSharedRole( address contract_, bytes32 role_, address challenger_ ) public view returns ( bool ) {
        RoleData.Role storage role_ = _contractRoles[contract_].roles[role_];

        for( uint256 iteration = 0; iteration < role_.restrictedSharedRoles.length(); iteration++ ) {
            if ( _contractRoles[contract_].roles[role_.restrictedSharedRoles.at( iteration )].members.contains( challenger_ ) ) {
                return true;
            }
        }

        return false;
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount( address contract_, bytes32 role_ ) public view returns ( uint256 ) {
        return _contractRoles[contract_].roles[role_].members.length();
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
    function getRoleMember( address contract_, bytes32 role_, uint256 index_ ) public view returns ( address ) {
        return _contractRoles[contract_].roles[role_].members.at( index );
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
    function grantRole( address contract_, bytes32 role_, address account_ ) public onlyPlatform() {
        // console.log( "RoleBasedAccessControl::grantRole checking that %s is approved to have role.", account_ );
        
        require( _isApproveForRole( role_, account_ ), "RoleBasedAccessControl::grantRole Address is not approved for role." );
        // console.log( "RoleBasedAccessControl::grantRole checking that %s is admin to set role.", Context._msgSender() );
        
        require( hasRole(_contractRoles[contract_].roles[role].admin, Context._msgSender() ), "RoleBasedAccessControl: sender must be an admin to grant" );
        // console.log( "RoleBasedAccessControl::grantRole checking that %s does not have any restricted shared roles for role.", account_ );
        
        require( !hasRestrictedSharedRole( role_, account_ ), "RoleBasedAccessControl::grantRole account has restrictedSharedRoles with role." );
        // console.log( "RoleBasedAccessControl::grantRole Granting %s role.", account_ );
        
        _grantRole( contract_, role_, account_ );
        // console.log( "RoleBasedAccessControl::grantRole Granted %s role.", account_ );
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin( address contract_, address submitter_, bytes32 role_, bytes32 adminRole_ ) internal virtual {
        RoleData.Role storage roleData_ = _contractRoles[contract_].roles[role_];
        
        bytes32 previousAdminRole_ = roleData_.adminRole;
        roleData_.adminRole = adminRole_;

        // TODO: Add who did it
        _eventBroadcaster.roleAdminChanged( contract_, role_, previousAdminRole_, roleData_.adminRole );
    }

    function _setApproverRole( address contract_, address submitter, bytes32 role_, bytes32 approverRole_ ) internal virtual {
        RoleData.Role storage roleData_ = _contractRoles[contract_].roles[role_];
        
        bytes32 previousApproverRole__ = roleData_.approver;
        roleData_.approver = approverRole_;

        // TODO: Add who did it
        _eventBroadcaster.roleApproverChanged( contract_, role_, previousApproverRole__, roleData_.approver );
    }

    function _addRestrictedSharedRoles( address contract_, address submitter_, bytes32 role_, bytes32 restrictedSharedRole_ ) internal virtual {        
        _contractRoles[contract_].roles[role_].restrictedSharedRoles.add( restrictedSharedRole_ );

        // TODO: Add who did it
        _eventBroadcaster.restrictedSharedRoleAdded( contract_, role_, restrictedSharedRole_ );
    }

    function _grantRole( address contract_, bytes32 role_, address account_ ) private {
        // console.log("RoleBasedAccessControl: Granting %s role.", account);

        RoleData.Role storage roleData_ = _contractRoles[contract_].roles[role_];

        if (roleData_.members.add( account_ )) {
            _eventBroadcaster.roleGranted( contract_, role_, account_, Context._msgSender() );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin( address contract_, bytes32 role_ ) public view returns ( bytes32 ) {
        return _contractRoles[contract_].roles[role_].admin;
    }

    function isApprovedForRole( bytes32 role_, address queryAddress_ ) public view returns ( bool ) {
        return _isApproveForRole( role_, queryAddress_ );
    }

    function approveForRole( address contract_, bytes32 role_, address approvedAccount_ ) public virtual {
        require( _hasRole( contract_, _contractRoles[contract_].roles[role_].approver, Context._msgSender() ), "RoleBasedAccessControl::approveForRole caller is not role approver." );
        _approveForRole( contract_, role_, approvedAccount_ );
    }

    function revokeApproval( address contract_, bytes32 role_, address disapprovedAccount_ ) public virtual {
        require( _hasRole( contract_, _contractRoles[contract_].roles[role_].approver, Context._msgSender() ), "RoleBasedAccessControl::approveForRole caller is not role approver." );
        _revokeRoleApproval( contract_, role_, disapprovedAccount_ );
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
    function revokeRole( address contract_, bytes32 role_, address account_ ) public virtual {
        require( _hasRole( contract_, _contractRoles[contract_].roles[role_].admin, Context._msgSender() ), "AccessControl: sender must be an admin to revoke" );
        _revokeRole( contract_, role_, account_ );
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
    function renounceRole( address contract_, bytes32 role, address account_ ) public virtual {
        require( account == Context._msgSender(), "AccessControl: can only renounce roles for self" );
        _revokeRole( contract_, role_, account_ );
    }

    function _hasRole( address contract_, bytes32 role_, address account_ ) public view returns ( bool ) {
        return _contractRoles[contract_].roles[role_].members.contains( account_ );
    }

    function _revokeRole( address contract_, bytes32 role_, address account_ ) internal {
        if ( _contractRoles[contract_].roles[role_].members.remove( account_ ) ) {
            _eventBroadcaster.roleRevoked( contract_, role_, account_, Context._msgSender() );
        }
    }

    function _approveForRole( address contract_, bytes32 role_, address approvedAccount_ ) internal {
        // What is the difference between RoleApproved and RoleGranted?
        emit RoleApproved( role_, Context._msgSender(), approvedAccount_ );
        contractRoles[contract_].roles[role_].roleApproval[approvedAccount_] = true;
    }

    function _revokeRoleApproval( address contract_, bytes32 role_, address revokedAccount_ ) internal {
        emit ApprovalRevoked( role_, Context._msgSender(), revokedAccount_ );
        _contractRoles[contract_].roles[role_].roleApproval[revokedAccount_] = false;
    }

    function _isApproveForRole( contract_, bytes32 role_, address queryAddress_ ) internal view returns ( bool ) {
        return _contractRoles[contract_].roles[role_].roleApproval[queryAddress_];
    }

    function _hasAnyOfRoles( bytes32[] storage roles_, address challenger_ ) internal view returns ( bool ) {

        // challenger_ is a stupid name, idfk what this is so idk what to do here
        // also, it's an address and this is checking in the byte ROLES

        for( uint256 iteration = 0; iteration <= roles_.length; iteration++ ){
            if( _hasRole( roles_[iteration], challenger_ ) ) { // This will error
                return true;
            }
        }

        return false;
    }

}