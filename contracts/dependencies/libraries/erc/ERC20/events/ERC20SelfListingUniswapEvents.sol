// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

library ERC20SelfListingUniswapEvents {
    // Event to alert users that the UniswapV2 factory address has been change.
    event UniswapV2FactoryAddressChanged( address indexed previousUniswapV2FactoryAddress, address indexed newUniswapV2FactoryAddress);

    // Event to alert users that the UniswapV2 router address has been changed.
    event UniswapV2RouterAddressChanged( address indexed previousUniswapV2RouterAddress, address indexed newUniswapV2RouterAddress);

    // Event to alert users that the ERIS WETH dex pair has been created.
    event UniswapV2ERISWETHDEXPairCreated( address indexed uniswapV2ErisWETHDEXPairdAddress, address indexed erisAddress, address indexed wethAddress );

    // Event to alert users that the address for the ERIS WETH dex pair address has changed.
    event UniswapV2ERISWETHPairAddressChanged( address indexed previousUniswapV2ErisWETHAddress, address indexed newUniswapV2ErisWETHPairAddress);
}