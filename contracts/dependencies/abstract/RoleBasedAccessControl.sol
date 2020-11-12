// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../libraries/constants/Roles.sol";
// import "../libraries/dataTypes/primitives/Address.sol";
// import "../libraries/security/Context.sol";
// import "../libraries/dataTypes/collections/EnumerableSet.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
 // *****************************************************************************************************
 // Should be turned into an Interface for clients to access both the AuthorizationPlatform and Authroization Datastore
 // *****************************************************************************************************
abstract contract RoleBasedAccessControl {

    // using EnumerableSet for EnumerableSet.AddressSet;
    // using EnumerableSet for EnumerableSet.Bytes32Set;
    // using Address for address;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    // event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    // event RoleAdpproverChanged(bytes32 indexed role, bytes32 indexed previousApproverRole, bytes32 indexed newApproverRole);

    // event RestrictedSharedRoleAdded( bytes32 indexed roleWithRestrictedSharedRole, bytes32 indexed addedRestrictedSharedRole );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    // event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    // event RoleApproved( bytes32 indexed role, address indexed approver, address indexed account );

    // event ApprovalRevoked( bytes32 indexed role, address indexed approver, address indexed disapprovedAccount );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    // event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // modifier onlyRole( bytes32 role_ ) {
    //     require( hasRole( role_, Context._msgSender() ), "RoleBasedAccessControl: account for not has authroized role for action." );
    //     _;
    // }

    // modifier notRole( bytes32 role_ ) {
    //     require( !hasRole( role_, Context._msgSender() ) );
    //     _;
    // }
    
    // struct RoleData {
    //     EnumerableSet.AddressSet members;
    //     bytes32 adminRole;
    //     bytes32 approverRole;
    //     EnumerableSet.Bytes32Set restrictedSharedRoles;
    //     mapping(address => bool) roleApproval;
    // }

    // mapping (bytes32 => RoleData) private _roles;

    constructor() {
        console.log( "Instantiating RoleBasedAccessControl." );
        console.log( "Instantiated RoleBasedAccessControl." );
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
        return _roles[role].members.length();
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
    function grantRole(bytes32 role, address account) public virtual {
        console.log("RoleBasedAccessControl::grantRole checking that %s is approved to have role.", account );
        require( _isApproveForRole( role, account ), "RoleBasedAccessControl::grantRole Address is not approved for role." );
        console.log("RoleBasedAccessControl::grantRole checking that %s is admin to set role.", Context._msgSender());
        require(hasRole(_roles[role].adminRole, Context._msgSender()), "RoleBasedAccessControl: sender must be an admin to grant");
        console.log("RoleBasedAccessControl::grantRole checking that %s does not have any restricted shared roles for role.", account);
        require( !hasRestrictedSharedRole( role, account ), "RoleBasedAccessControl::grantRole account has restrictedSharedRoles with role." );
        console.log("RoleBasedAccessControl::grantRole Granting %s role.", account);
        _grantRole(role, account);
        console.log("RoleBasedAccessControl::grantRole Granted %s role.", account);
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

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _addRestrictedSharedRoles( bytes32 role, bytes32 restrictedSharedRole ) internal virtual {
        emit RestrictedSharedRoleAdded( role, restrictedSharedRole );
        _roles[role].restrictedSharedRoles.add( restrictedSharedRole );
    }

    function _setApproverRole( bytes32 role, bytes32 newApproverRole ) internal {
        emit RoleAdpproverChanged( role, _roles[role].approverRole, newApproverRole);
        _roles[role].approverRole = newApproverRole;
    }

    function _grantRole(bytes32 role, address account) private {
        console.log("RoleBasedAccessControl: Granting %s role.", account);
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, Context._msgSender());
        }
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
