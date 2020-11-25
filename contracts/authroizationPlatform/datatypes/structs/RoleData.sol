// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "../../dataTypes/collections/AddressSet.sol";
import "../../dataTypes/collections/Bytes32Set.sol";

// TODO: Better description
// TODO: RoleData - roleApproval bool should be a struct containing data about who approved etc. for more information .

/**
 * @notice Datatype for reuse in the authroization system.
 */
library RoleData {

    using AddressSet for AddressSet.AddressSet;
    using Bytes32Set for Bytes32Set.Bytes32Set;

    struct Role {
        bytes32 admin;
        bytes32 approver;
        AddressSet.AddressSet members;
        Bytes32Set.Bytes32Set restrictedSharedRoles;    // TODO: Better name
        mapping(address => bool) approved;
    }

    struct ContractRoles {
        bytes32 root;
        mapping(bytes32 => Role) roles;
    }

}