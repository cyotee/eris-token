/**
Library to list and deposit a token on a uniswap Compatiable exchange.
 */
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../libraries/dataTypes/collections/EnumerableSet.sol";

library TokenListingUniswapV2 {

    // Not sure all these properties are needed.
    // Just added what seemed like a good idea now.
    struct TokenListing {
        address tokenFromSale;
        uint256 tokenFromSaleAmount;
        address tokenToPair;
        uint256 TokenToPairAmount;
        address uniswapV2CompatibleRouter;
        address uniswapVsCompatibleFactory;
    }

    
    // Not sure all these properties are needed.
    // Just added what seemed like a good idea now.
    struct SaleData {
        address tokenForSale;
        bool saleActive;
        uint256 saleStartTimeStamp;
        uint256 saleEndTimeStamp;
        // Can also store the Thereum paid during a sale.
        uint256 amountOfTokenPaid;
        TokenListing tokenListing;
    }

    
}