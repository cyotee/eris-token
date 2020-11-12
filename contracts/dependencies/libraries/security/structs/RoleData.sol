// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "../libraries/dataTypes/collections/AddressSet.sol";
import "../libraries/dataTypes/collections/Bytes32Set.sol";

// TODO: Better description
// TODO: RoleData - roleApproval bool should be a struct containing data about who approved etc. for more information .

/**
 * @notice Datatype for reuse in the authroization system.
 */
library RoleData {

    using AddressSet for AddressSet.AddressSet;
    using Bytes32Set for Bytes32Set.Bytes32Set;

    struct RoleData {
        bytes32 adminRole;
        bytes32 approverRole;
        AddressSet.AddressSet members;
        Bytes32Set.Bytes32Set restrictedSharedRoles;
        mapping(address => bool) roleApproval;
    }

    struct ContractRoles {
        bytes32 rootRole;
        mapping(bytes32 => RoleData) roles;
    }

}