// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "./SafeFullMath.sol";

library FinancialSafeMath {

    using SafeFullMath for uint256;

        function quadraticPricing( uint256 payment ) internal pure returns (uint256) {
        return payment.mul(2).sqrrt();
    }

        function bondingPrice( uint256 multiplier, uint256 supply ) internal pure returns (uint256) {
        return multiplier.mul( supply );
    }
}