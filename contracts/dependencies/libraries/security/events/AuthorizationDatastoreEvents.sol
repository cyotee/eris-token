// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

library AuthorizationDatastoreEvents {

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged( address indexed _contract, address submitter, bytes32 indexed role, bytes32 previousAdminRole, bytes32 indexed newAdminRole );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted( address indexed _contract, bytes32 indexed role, address grantee, address indexed grantor );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked( address indexed _contract, bytes32 indexed role, address indexed account, address sender );

    event RoleRemoved( address indexed _contract, bytes32 indexed role, address indexed account, address sender );

    event RoleApproverChanged( address indexed _contract, address submitter, bytes32 indexed role, bytes32 approverRole, bytes32 indexed newApproverRole );

    event RestrictedSharedRoleAdded( address indexed _contract, bytes32 indexed role, bytes32 indexed restrictedSharedRole );

    event NewContractRegistered( address indexed newRegisteredContract, bytes32 indexed rootRole, address indexed rootAdminAddress );

    event CreatedRole( address indexed _contract, address indexed submitter, bytes32 role );
}