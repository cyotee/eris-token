// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../libraries/utils/listing/uniswapV2/TokenListingUniswapV2Compatible.sol";

/**
Contract to execute the sale of a mintable token using a quadratic pricing model.
 */
contract QPLGMESalePlatform is RoleBasedAccessControl {

    using TokenListingUniswapV2Compatible for TokenListingUniswapV2Compatible.TokenListing;
    using TokenListingUniswapV2Compatible for TokenListingUniswapV2Compatible.SaleData;

    // Intended to hold DEX information in a form that can be maintained over time.
    mapping( address => address ) private _uniswapV2CompatibleExchangeRouterToFactoryMapping;

    mapping( bytes32 => TokenListingUniswapV2Compatible.SaleData ) private _saleDataMapping;

    // constructor() {}

    /**
     * TODO: needs authorization integration to limit access to platform admin
     */
    function registerExchange( address uniswapV2CompatibleRouterddress_, address exchangeFactoryAddress_ ) public {
        _uniswapV2CompatibleExchangeRouterToFactoryMapping[exhchangeRouterAddress_] = exchangeFactoryAddress_;
    }

    /**
     * Intended to provide a small UUID style identifier generated from the minimum amount of date needed to uniquely identify a sale.
     * Because UniswapV2 compatible exchanges use a router contract as the primary
     */
     // TODO Needs an event.
    function encodeSaleID(address saleToken_, address proceedsToken_, address uniswapV2CompatibleRouterddress_) public pure returns ( bytes32 ) {
        return _encodeSaleID(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_);
    }

    function _encodeSaleID(address saleToken_, address proceedsToken_, address uniswapV2CompatibleRouterddress_) internal pure returns ( bytes32 ) {
        return bytes32(keccak256(abi.encodePacked(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_)));
    }

    /**
     * 
     * Sales for Ethereum will use the WETH token address.
     *  might need to save WETH address and use IWETH interface.
     */
    // TODO Sales will need to check if proceedsToken_ is the WETH address and accept Ethereum to automatically convert to WETH.
    // TODO needs to confirm _msgSender() has correct role to register sale.
    // TODO needs an event.
    function registerSale(address saleToken_, address proceedsToken_, address uniswapV2CompatibleRouterddress_)  public {
        require(_uniswapV2CompatibleExchangeRouterToFactoryMapping[uniswapV2CompatibleRouterddress_] != 0, "QPLGMESalePlatform not compaitble with the exchange.");

        bytes32 saleID = _encodeSaleID(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_);

        _saleDataMapping[saleID].saleActive = false;
        _saleDataMapping[saleID].listerAddress = Context._msgSender();
        _saleDataMapping[saleID].tokenForSale = tokenForSale_;
        _saleDataMapping[saleID].proceedsToken = proceedsToken_;
        _saleDataMapping[saleID].tokenListing.uniswapV2CompatibleRouter = IUniswapV2Router02(uniswapV2CompatibleRouterddress_);
        _saleDataMapping[saleID].tokenListing.uniswapVsCompatibleFactory = IUniswapV2Factory(_uniswapV2CompatibleExchangeRouterToFactoryMapping[uniswapV2CompatibleRouterddress_]);

        _listToken(saleID);
    }

    // TODO Needs event announcing listing has occured and reporting addresses.
    function _listToken(bytes32 saledID_) private {
        require(_saleDataMapping[saledID_] != 0, "Sale ID does not exist.");
        _saleDataMapping[saleID]
            .tokenListing
            .uniswapV2CompatiblePair = IUniswapV2Pair(
                saleDataMapping[saleID]
                    .tokenListing
                    .uniswapV2CompatibleRouter
                        .createPair(
                            _saleDataMapping[saleID].tokenForSale, 
                            _saleDataMapping[saleID].proceedsToken
                        )
                    );
    }

/* -------------------------------------------------------------------------- */
/*              Functions for reuse in platform reimplementation              */
/* -------------------------------------------------------------------------- */

    // address internal devAddress;
    // address public charityAddress;

    // uint256 public qplgmeStartTimestamp;
    // uint256 public qplgmeEndTimestamp;
    // bool public qplgmeActive = false;
    // bool public hadQPLGME = false;
    // uint256 public qplgmeLength = 3 days;
    // uint256 public qplgmeLength = 30 minutes;
    // uint8 private _erisToEthRatio = 5;
    // uint8 private _transferFeePercentage = 10;

    // uint256 public ethDonationToCharity;
    // uint256 public totalWeiPaidForEris;
    // uint256 public _totalLPTokensMinted;
    // uint256 public _lpPerETHUnit;

    // mapping ( address => uint256 ) private _weiPaidForErisByAddress;

    // Should be storing data of token address from sale by token address to be paired after sale by sale data.
    // mapping( address => mapping( address => SaleData ) ) private _tokenSales;

    // mapping( address => mapping( address => mapping( address => SaleData) ) ) private _saleDataBytExchangeRouterBytProceedsTokenBySaleToken;

    // function getSecondsLeftInLiquidityGenerationEvent() public view returns (uint256) {
    //     return qplgmeStartTimestamp.add(qplgmeLength).sub(block.timestamp);
    // }

    // function startQPLGME() public onlyOwner() erisQPLGMEInactive() notHadQPLGME() {
    //     qplgmeActive = true;
    //     qplgmeStartTimestamp = block.timestamp;
    //     emit QPLGMEStarted( qplgmeActive, qplgmeStartTimestamp );
    // }

    // function quadraticPricewithAdditionalPayment( address buyer, uint additionalAmountPaid ) public view returns ( uint ) {
    //     return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[buyer].add( additionalAmountPaid ) ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function erisForWeiPaid( uint256 payment ) public view returns ( uint256 ) {
    //     return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function _erisForWeiPaid( uint256 payment ) private view returns ( uint256 ) {
    //     return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    // }

    // function buyERIS( uint256 amount) public payable erisQPLGMEActive() {
    //     uint256 amountPaidInWEI = amount;
    //     _testToken.transferFrom( _msgSender(), address(this), amount);

    //     uin256 memory currentBuyersWeirPaidForEris_ = _weiPaidForErisByAddress[_msgSender()];
    //     _weiPaidForErisByAddress[_msgSender()] = _weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI);

    //     totalWeiPaidForEris = totalWeiPaidForEris.add(_weiPaidForErisByAddress[_msgSender()]).sub( currentBuyersWeirPaidForEris_ );

    //     _totalSupply = _totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()] ) );

    //     ethDonationToCharity = ethDonationToCharity.add( _weiPaidForErisByAddress[_msgSender()] / 10 ).sub( currentBuyersWeirPaidForEris_.div(10) );
    // }

    // function endQPLGME() public onlyOwner() {
    //     if( !hadQPLGME ) {
    //         _completeErisGME();
    //     }
    //     emit QPLGMEEnded( qplgmeActive, qplgmeEndTimestamp );
    // }

    // function collectErisFromQPLGME() public erisQPLGMEInactive() {
    //     if( !hadQPLGME ) {
    //         _completeErisGME();
    //     }

    //     if( _weiPaidForErisByAddress[_msgSender()] > 0 ){
    //         uint256 weiPaidForErisByAddress_ = _weiPaidForErisByAddress[_msgSender()];
    //         _weiPaidForErisByAddress[_msgSender()] = 0;
    //         _balances[_msgSender()] =  _erisForWeiPaid( weiPaidForErisByAddress_ );
    //     }
    // }

    // function _completeErisGME() private  {
    //     qplgmeEndTimestamp = block.timestamp;
    //     qplgmeActive = false;
    //     hadQPLGME = true;

    //     // _balances[charityAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
    //     _balances[charityAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
    //     _totalSupply = _totalSupply.add(_balances[charityAddress]);
    //     // ethDonationToCharity = _weth.balanceOf( address(this) ).div(10);
    //     ethDonationToCharity = _testToken.balanceOf( address(this) ).div(10);

    //     // erisDueToReserves = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );

    //     _fundReservesAndSetTotalSupply();
    //     _collectDonationToCharity();
    //     _depositInUniswap();
    // }

    // function _fundReservesAndSetTotalSupply() private {
    //     fundCharity();
    //     fundDev();
    // }

    // function fundDev() private {
    //     // _balances[devAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
    //     _balances[devAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
    //     _totalSupply = _totalSupply.add(_balances[devAddress]);
    // }

    // function fundCharity() private {
    // }

    // function _collectDonationToCharity() private {
    //     require( ethDonationToCharity > 0 );
    //     ethDonationToCharity = 0;
    //     // _weth.transfer( charityAddress, _weth.balanceOf( address(this) ).div(10) );
    //     _testToken.transfer( charityAddress, _testToken.balanceOf( address(this) ).div(10) );
    // }

    // function _depositInUniswap() private {
    //     // totalWeiPaidForEris = _weth.balanceOf( address(this) );
    //     totalWeiPaidForEris = _testToken.balanceOf( address(this) );
    //     _balances[address(_uniswapV2ErisWETHDEXPair)] = FinancialSafeMath.bondingPrice( _totalSupply.div(totalWeiPaidForEris), _totalSupply ).mul(_erisToEthRatio).div(1e2);
    //     // _weth.transfer( address(_uniswapV2ErisWETHDEXPair), _weth.balanceOf( address(this) ) );
    //     _testToken.transfer( address(_uniswapV2ErisWETHDEXPair), _testToken.balanceOf( address(this) ) );
    //     _uniswapV2ErisWETHDEXPair.mint(address(this));
    //     _totalLPTokensMinted = _uniswapV2ErisWETHDEXPair.balanceOf(address(this));
    //     require(_totalLPTokensMinted != 0 , "No LP deposited");
    //     _lpPerETHUnit = _totalLPTokensMinted.mul(1e18).div(totalWeiPaidForEris);
    //     require(_lpPerETHUnit != 0 , "Eris:292:_depositInUniswap(): No LP deposited");
    // }

    // function erisDueToBuyerAtEndOfLGE( address buyer ) public view returns ( uint256 ){
    //     return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[ buyer ] ).mul(_erisToEthRatio).mul(1e9);
    //     //return _erisForWeiPaid( _weiPaidForErisByAddress[ buyer ] );
    // }

    // function withdrawPaidETHForfietAllERIS() public erisQPLGMEActive() {
    //     uint256 weiPaid = _weiPaidForErisByAddress[_msgSender()];
    //     _weiPaidForErisByAddress[_msgSender()] = 0 ;
    //     _balances[_msgSender()] = 0;
    //     totalWeiPaidForEris = totalWeiPaidForEris.sub( weiPaid );
    //     ethDonationToCharity = ethDonationToCharity.sub( weiPaid.div(10) );
    //     // _weth.withdraw( weiPaid );
    //     // _msgSender().transfer( weiPaid );
    //     _testToken.transfer( _msgSender(), weiPaid );
    // }
}