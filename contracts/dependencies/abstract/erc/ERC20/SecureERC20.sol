// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "../../libraries/security/constants/Roles.sol";

abstract contract SecureERC20 is ERC20, AuthorizationPlatformClient {

    function mint( address acount_, uint256 amount_ ) public hasOnlyRole( Roles.MINTER_ROLE, Context._msgSender() {
        
    }
}