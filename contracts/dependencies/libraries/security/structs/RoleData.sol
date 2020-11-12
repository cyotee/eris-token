// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../../primitives/Address.sol";
import "../../libraries/security/Context.sol";
import "../libraries/dataTypes/collections/EnumerableSet.sol";

/**
 * RoleData datatype for reus in authroization system.
 */
library RoleData {

    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
        bytes32 approverRole;
        EnumerableSet.Bytes32Set restrictedSharedRoles;
        mapping(address => bool) roleApproval;
    }

    struct ContractRoles {
        mapping( bytes32 => RoleData ) roles;
        bytes32 rootRole;
    }

}