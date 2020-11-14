// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

interface IAuthorizationPlatform {

    function hasRole( address contract_, bytes32 role_, address account_ ) external view returns ( bool );
}