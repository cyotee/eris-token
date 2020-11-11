/**
Contract to execute the sale of a mintable token using a quadratic pricing model.
 */
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

contract QPLGMESalePlatform is RoleBasedAccessControl {

    using TokenListingUniswapV2 for TokenListingUniswapV2.TokenListing;
    using TokenListingUniswapV2 for TokenListingUniswapV2.SaleData

    mapping( address => SaleData[] ) tokenSales;

    function createPairOnUniswap() private {
        /*
        ***************** FOR TESTING ONLY *************************************************************
        */
        uniswapV2ErisWETHDEXPairAddress = address( _uniswapFactoryV2Factory.createPair( address(_testToken), address(this) ) );
        // _weth = IWETH(address(_uniswapV2Router.WETH()));
        // uniswapV2ErisWETHDEXPairAddress = address( uniswapFactoryV2Factory.createPair( address(_uniswapV2Router.WETH()), address(this) ) );
        _uniswapV2ErisWETHDEXPair = IUniswapV2Pair( uniswapV2ErisWETHDEXPairAddress );
    }
}