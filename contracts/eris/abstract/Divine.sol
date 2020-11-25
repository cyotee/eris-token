// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "./ERC20.sol";
import "./AccessControl.sol";
// import ".,/libraries/utils/math/SafeMath.sol";
// import ".,/libraries/datatypes/primitives/Address.sol";
// import "../libraries/datatypes/collections/EnumerableSet.sol";

/**
 * Intended to gather other abstract contracts and interfaces for Eris.
 */
abstract contract Divine is ERC20, RoleBasedAccessControl {

    // using Bytes32 for bytes32;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor () ERC20( "ERIS", "ERIS" ) {
        console.log("Divine::constructor: Instantiating Divine");
        console.log("Divine::constructor: Calling _initializeRoles()");
        _initializeRoles();
        console.log("Divine::constructor: Called _initializeRoles()");
        // _mint(_msgSender(), 50000 * 1**decimals()  );
        console.log("Divine::constructor: Instantiated Divine");
    }

    function _initializeRoles() internal {
        console.log("Divine::_initializeRoles: Calling _initializeDEFAULT_ADMIN_ROLE()");
        _initializeDEFAULT_ADMIN_ROLE();
        console.log("Divine::_initializeRoles: Called _initializeDEFAULT_ADMIN_ROLE()");
    }

    function _initializeDEFAULT_ADMIN_ROLE() internal {
        console.log("Divine::_initializeDEFAULT_ADMIN_ROLE: Calling _setupRole(bytes32 role, address account) internal virtual");
        console.log("Divine::_initializeDEFAULT_ADMIN_ROLE: Setting %s as %s.", _msgSender(), bytes32ToString( AccessControl.DEFAULT_ADMIN_ROLE ) );
        _setupRole(AccessControl.DEFAULT_ADMIN_ROLE, _msgSender());
        console.log("Divine::_initializeDEFAULT_ADMIN_ROLE: Set %s as %s.", _msgSender(), bytes32ToString( AccessControl.DEFAULT_ADMIN_ROLE ) );
        console.log("Divine::_initializeDEFAULT_ADMIN_ROLE: %s is %s: %s.", _msgSender(), bytes32ToString( AccessControl.DEFAULT_ADMIN_ROLE ), hasRole( AccessControl.DEFAULT_ADMIN_ROLE, _msgSender() ) );
        console.log("Divine::_initializeDEFAULT_ADMIN_ROLE: Called _setupRole(bytes32 role, address account) internal virtual");
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}