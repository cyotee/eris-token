// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../contracts/abstract/AccessControl.sol"
import "../contracts/abstract/ERC20.sol"

abstract RoleBasedAccessControl is AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

}