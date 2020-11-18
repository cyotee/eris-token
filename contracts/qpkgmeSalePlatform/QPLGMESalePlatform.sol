// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "../libraries/utils/listing/uniswapV2/TokenListingUniswapV2Compatible.sol";
import "../dependencies/libraries/utils/time/interfaces/IDateTime.sol";
import "../dependencies/libraries/datatypes.primitives/Address.sol";

/**
 * Contract to execute the sale of a mintable token using a quadratic pricing model.
 */
// TODO Need to be AccessControlPlatfomrClient
// TODO needs interface.
contract QPLGMESalePlatform {

    using Address for address;
    using SafeERC20 for IERC20;
    using TokenListingUniswapV2Compatible for TokenListingUniswapV2Compatible.TokenListing;
    using TokenListingUniswapV2Compatible for TokenListingUniswapV2Compatible.SaleData;

    // TODO needs function to update address;
    IDateTime private _dateTimeCalculator;
    // TODO needs function to update address;
    IWETH private _weth;
    // TODO needs function to update address;
    ISaleProceedsVault private _saleProceedsVault;
    // TODO needs function to update address;
    ISaleProceedsVault private salesProceedsVault;

    // Intended to hold DEX information in a form that can be maintained over time.
    // Coupled with the 
    mapping( address => address ) private _uniswapV2CompatibleExchangeRouterToFactoryMapping;

    mapping( bytes32 => TokenListingUniswapV2Compatible.SaleData ) private _saleDataMapping;

    // constructor() {}

    // TODO need initialization function to register and confgiure roles with AuthorizationPlatform.

    // TODO: needs authorization integration to limit access to platform admin
    // TODO needs exchange listing tester to enable public registering of exchanges. This should confirm compatibility by minting 2 test tokens, listing, and attempting to trade. Can be implemented as an adaptor for later development
    // TODO confirm ic this can be reused for Balancer.
    function registerExchange( address uniswapV2CompatibleRouterddress_, address exchangeFactoryAddress_ ) public {
        require( uniswapV2CompatibleRouterddress_.isContract() && exchangeFactoryAddress_.isContract() );
        _uniswapV2CompatibleExchangeRouterToFactoryMapping[exhchangeRouterAddress_] = exchangeFactoryAddress_;
    }

    /**
     * Intended to provide a small UUID style identifier generated from the minimum amount of date needed to uniquely identify a sale.
     * Because UniswapV2 compatible exchanges use a router contract as the primary integration point the router address is used as the exchange identifier.
     */
     // TODO Needs an event.
     // Investigate Balancer architecture to confirm if this can be reused for Balancer or if Balancer will need it's own saleID generation function.
    function encodeSaleID(address saleToken_, address proceedsToken_, address uniswapV2CompatibleRouterddress_) public pure returns ( bytes32 ) {
        return _encodeSaleID(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_);
    }

    function _encodeSaleID(address saleToken_, address proceedsToken_, address uniswapV2CompatibleRouterddress_) internal pure returns ( bytes32 ) {
        return bytes32(keccak256(abi.encodePacked(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_)));
    }

    // TODO needs function to convert Ethereum to WETH. Should used as early as possible when accepting payments.

    /**
     * Sales for Ethereum will use the WETH token address.
     *  might need to save WETH address and use IWETH interface.
     */
    // TODO Sales will need to check if proceedsToken_ is the WETH address and accept Ethereum to automatically convert to WETH.
    // TODO needs to confirm _msgSender() has correct role to register sale.
    // TODO needs an event.
    // TODO check reasibility of moving to independent datatore.
    function registerSale( address saleToken_, uint256 saleTokenQPMultiplier_, address proceedsToken_, address uniswapV2CompatibleRouterddress_ )  public {
        require(_uniswapV2CompatibleExchangeRouterToFactoryMapping[uniswapV2CompatibleRouterddress_] != 0, "QPLGMESalePlatform not compaitble with this exchange.");

        bytes32 saleID_ = _encodeSaleID(saleToken_, proceedsToken_, uniswapV2CompatibleRouterddress_);

        _saleDataMapping[saleID_].saleActive = false;
        _saleDataMapping[saleID_].listerAddress = Context._msgSender();
        _saleDataMapping[saleID_].tokenForSale = tokenForSale_;
        _saleDataMapping[saleID_].saleTokenQPMultiplier = saleTokenQPMultiplier_;
        _saleDataMapping[saleID_].proceedsToken = proceedsToken_;
        _saleDataMapping[saleID_].tokenListing.uniswapV2CompatibleRouter = IUniswapV2Router02(uniswapV2CompatibleRouterddress_);
        _saleDataMapping[saleID_].tokenListing.uniswapVsCompatibleFactory = IUniswapV2Factory(_uniswapV2CompatibleExchangeRouterToFactoryMapping[uniswapV2CompatibleRouterddress_]);

        _listToken(saleID_);
    }

    // TODO Needs event announcing listing has occured and reporting addresses.
    function _listToken(bytes32 saledID_) private {
        require( _saleDataMapping[saledID_] != 0, "Sale ID does not exist." );
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

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleStart(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_, uint8 second_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_, uint8 second_);
    }
    
    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleStart(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleStart(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleStart(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_;
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleStart(bytes32 saleID_, uint256 saleStartDateTime_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = saleStartDateTime_;
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleEnd(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_, uint8 second_) public returns (bool) {
        _saleDataMapping[saleID_].saleEndTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_, uint8 second_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleEnd(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_) public returns (bool) {
        _saleDataMapping[saleID_].saleEndTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_, uint8 minute_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleEnd(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_, uint8 hour_) public returns (bool) {
        _saleDataMapping[saleID_].saleStartTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_, uint8 hour_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleEnd(bytes32 saleID_, uint16 year_, uint8 month_, uint8 day_) public returns (bool) {
        _saleDataMapping[saleID_].saleEndTimeStamp = dateTimeCalculator.toTimestamp(uint16 year_, uint8 month_, uint8 day_);
    }

    // TODO needs integration to authorization to confirm msg.sender is authorized to configure sale.
    function scheduleSaleEnd(bytes32 saleID_, uint256 saleEndTimeStamp_) public returns (bool) {
        _saleDataMapping[saleID_].saleEndTimeStamp = saleEndTimeStamp_;
    }

    function getSaleStartDateTimeStamp(bytes32 saleID_) public returns (uint256) {
        return _saleDataMapping[saleID_].saleStartTimeStamp;
    }

    function getSaleEndDateTimeStamp(bytes32 saleID_) public returns (uint256) {
        return _saleDataMapping[saleID_].saleEndTimeStamp;
    }

    // TODO implement check that msg.sender has role to activate sale for token.
    // TODO implement check to confirm sale approver has approved sale configuration.
    function activateSale( bytes32 saleID_ ) public returns (bool) {
        require( _saleDataMapping[saleID_].saleActivesaleActive ==  false );
    }

    // Intended to be called as part of collecting token from sale.
    function _finalizeSale(bytes32 saleID) internal {
        require( _saleDataMapping[saleID_].saleActivesaleActive ==  true && block.timestamp > _saleDataMapping[saleID_].saleEndTimeStamp );
    }

    // TODO needs sale start time query function. Should return human readable date.

    // TODO needs function update schedule for a sale.
    // Intended to facilitate a second sale, or to reschedule a yet to begin sale.
    // Must confirm that sale is not active.

    // TODO needs function to accept payments for a sale.
    // Must confirm that sale is active. After sale start datetime and before sale end datetime.

    // TODO needs function to finalize sale.
    // Must deposit sale and proceed tokens in exchange.
    // Must archive sales data and token listing.
    // Should be internal for reuse.

    // TODO needs public function wrapping private function to finalize sale.
    
    // TODO needs function to collect sale tokens from sale.
    // Must confirm that sale is ended by checking datetime.
    // Should execute the finalize sale function if not already finalized.

    function _convertETHtoWETH( unint256 amount_ ) internal returns ( uint256 ) {
        _weth.deposit{value : amount_}();
        _weth.transfer{ address(salesProceedsVault) _salesProceedsVault}
        return amount_;
    }

    function _buyToken( bytes32 saleID_, address buyer_, uint256 amountPaid_ ) internal {
        _saleDataMapping[saleID_].dec18AmountOfTokenPaidByAddress[buyer_] = _saleDataMapping[saleID_].dec18AmountOfTokenPaidByAddress[buyer_].add(amountPaid_);
        _saleDataMapping[saleID_].dec18TotalAmountOfTokenPaid = _saleDataMapping[saleID_].dec18TotalAmountOfTokenPaid.add( amountPaid_ );

        uint256 saleTokenAmountPurchased_ = _calculateTokensForPayment( saleID_ , _saleDataMapping[saleID_].dec18AmountOfTokenPaidByAddress[buyer_]  );

        ISecureERC20( _saleDataMapping[saleID_].tokenForSale ).burn( _saleDataMapping[saleID_].tokenForSale, _saleDataMapping[saleID_].dec18AmountOfTokenPaidByAddress[buyer_].sub( amountPaid_ ) );

        ISecureERC20( _saleDataMapping[saleID_].tokenForSale ).mint( _saleDataMapping[saleID_].tokenForSale, _saleDataMapping[saleID_].dec18AmountOfTokenPaidByAddress[buyer_] );
    }

    function _calculateTokensForPayment( bytes32 saleID_, uint256 payment_ ) private view returns ( uint256 ) {
        return FinancialSafeMath.quadraticPricing( payment ).mul( _saleDataMapping[saleID_].saleTokenQPMultiplier );
        // Was needed for Wei calculation
        //.mul(1e9)
    }

    function buyTokenWithETH( bytes32 saleID_ ) public payable {

        uint256 currentVaultWETHBalance_ = _weth.balanceOf( address(_salesProceedsVault) );
        uint256 amountPaid_ = _convertETHtoWETH(msg.value);
        require( _weth.balanceOf( address(salesProceedsVault) ) > 0 );
        require( currentVaultWETHBalance_ == _weth.balanceOf( address(salesProceedsVault) ).sub( amountPaid_ ) );

        _buyToken( saleID_, acontext._msgSender(), amountPaid_ );
    }

    function getTokenForSale( bytes32 saleID_ ) public returns ( address ) {
        return _saleDataMapping[saleID_].tokenForSale;
    }

    function buyTokenWithToken( bytes32 memory saleID_, uint256 amountPaid_ ) internal {
        uint256 amountPaidInToken = amountPaid_;
        IERC20(_saleDataMapping[saleID_].tokenForSale).safeTransferFrom( _msgSender(), address(_saleProceedsVault), amount);

        uin256 memory currentBuyersWeirPaidForEris_ = _weiPaidForErisByAddress[_msgSender()];
        _weiPaidForErisByAddress[_msgSender()] = _weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI);

        totalWeiPaidForEris = totalWeiPaidForEris.add(_weiPaidForErisByAddress[_msgSender()]).sub( currentBuyersWeirPaidForEris_ );

        _totalSupply = _totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()] ) );

        ethDonationToCharity = ethDonationToCharity.add( _weiPaidForErisByAddress[_msgSender()] / 10 ).sub( currentBuyersWeirPaidForEris_.div(10) );
    }

/* -------------------------------------------------------------------------- */
/*              Functions for reuse in platform reimplementation              */
/* -------------------------------------------------------------------------- */

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