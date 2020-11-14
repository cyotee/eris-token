// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

library RoleBasedAccessControlEvents {

    event RoleAdminChanged( bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole );

    event RoleApproverChanged( bytes32 indexed role, bytes32 indexed previousApproverRole, bytes32 indexed newApproverRole );

    event RestrictedSharedRoleAdded( bytes32 indexed roleWithRestrictedSharedRole, bytes32 indexed addedRestrictedSharedRole );

    event RoleGranted( bytes32 indexed role, address indexed account, address indexed sender );

    event RoleApproved( bytes32 indexed role, address indexed approver, address indexed account );

    event ApprovalRevoked( bytes32 indexed role, address indexed approver, address indexed disapprovedAccount );

    event RoleRevoked( bytes32 indexed role, address indexed account, address indexed sender );
}