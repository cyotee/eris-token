// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../libraries/dataTypes/collections/EnumerableSet.sol";

/**
 * Library to list and deposit a token on a uniswap Compatiable exchange.
 */
library TokenListingUniswapV2Compatible {

    // Not sure all these properties are needed.
    // Just added what seemed like a good idea now.
    struct TokenListing {
        // address tokenFromSale;
        uint256 tokenFromSaleAmount;
        address tokenToPair;
        uint256 tokenToPairAmount;
        IUniswapV2Router02 uniswapV2CompatibleRouter;
        IUniswapV2Factory uniswapVsCompatibleFactory;
        IUniswapV2Pair uniswapV2CompatiblePair;
    }

    struct DispersalData {
        address teamAllotmentAddress;
        // Not sure about including this option as the QP and bonding curve model are intended to calculate this organically.
        uint256 teamSaleTokenAllotment;
        bool teamSaleTokenAllotmentPercentage;
        uint256 teamProceedTokenAllotment;
        bool teamProceedTokenAllotmentPercentage;
        address projectAllotmentAddress;
        // Not sure about including this option as the QP and bonding curve model are intended to calculate this organically.
        uint256 projectSaleTokenAllotment;
        bool projectSaleTokenAllotmentPercentage;
        uint256 projectProceedTokenAllotment;
        bool projectProceedTokenAllotmentPercentage;
    }

    // Not sure all these properties are needed.
    // Just added what seemed like a good idea now.
    struct SaleData {
        bytes32 saleAdminRole;
        bytes32 saleApprovalRole;
        bool saleActive;
        address listerAddress;
        address tokenForSale;
        // Use WETH address for sales receiving Ethereum.
        address proceedsToken;
        // Intended to sotre how long a sale will last.
        // Might not be needed as the start and end timestamps could achieve the same thing automatically.
        uint256 saleLength
        // Intended to store the time when a sale started.
        // Could be used to schedule a sale for the future.
        uint256 saleStartTimeStamp;
        // Intended to hold the time when a sale is concluded.
        // Could be used to schedule when a sale will end.
        uint256 saleEndTimeStamp;
        // Can also store the EThereum paid during a sale.
        uint256 dec18AmountOfTokenPaid;
        // Quadratic pricing model relies on tracking the amount paid over a sale.
        // Must track the amout paid for use when calculating the tokens to mint for collection at the end of the sale.
        mapping( address => unit256 ) amountOfTokenPaidByAddress;
        TokenListing tokenListing;
    }

}