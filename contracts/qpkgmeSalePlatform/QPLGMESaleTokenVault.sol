// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

/**
 * Intended to hold the balances of tokens sold.
 */
 // TODO needs to be AuthorizationPlatformClient.
contract QPLGMESaleTokenVault {

    using Address for address;
    using SafeERC20 for ERC20;

    mapping( bytes32 => ERC20 ) private _soldTokensBySaleID;


}