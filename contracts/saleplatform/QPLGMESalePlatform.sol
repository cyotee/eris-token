/**
Contract to execute the sale of a mintable token using a quadratic pricing model.
 */
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

contract QPLGMESalePlatform is RoleBasedAccessControl {

    using TokenListingUniswapV2 for TokenListingUniswapV2.TokenListing;
    using TokenListingUniswapV2 for TokenListingUniswapV2.SaleData

    event QPLGMEStarted( bool oplgmeActive, uint256 startTime );
    event QPLGMEEnded( bool oplgmeActive, uint256 startTime );

    modifier notHadQPLGME() {
        require( !hadQPLGME );
        _;
    }

    modifier erisQPLGMEActive() {
        require( 
            qplgmeActive 
            // && qplgmeStartTimestamp.add(qplgmeLength) > block.timestamp
            , "Eris::erisQPLGMEActive(): QPLGME inactive" 
        );
        _;
    }

    modifier erisQPLGMEInactive() {
        require( 
            !qplgmeActive 
            // || qplgmeStartTimestamp.add(qplgmeLength) < block.timestamp 
            , "Eris::erisQPLGMEInactive(): QPLGME active" 
        );
        _;
    }

    address internal devAddress;
    address public charityAddress;

    uint256 public qplgmeStartTimestamp;
    uint256 public qplgmeEndTimestamp;
    bool public qplgmeActive = false;
    bool public hadQPLGME = false;
    // uint256 public qplgmeLength = 3 days;
    uint256 public qplgmeLength = 30 minutes;
    uint8 private _erisToEthRatio = 5;
    uint8 private _transferFeePercentage = 10;

    uint256 public ethDonationToCharity;
    uint256 public totalWeiPaidForEris;
    uint256 public _totalLPTokensMinted;
    uint256 public _lpPerETHUnit;

    mapping ( address => uint256 ) private _weiPaidForErisByAddress;

    // Should be storing data of token address from sale by token address to be paired after sale by sale data.
    mapping( address => mapping( address => SaleData ) ) private _tokenSales;

    constructor() {}

    function getSecondsLeftInLiquidityGenerationEvent() public view returns (uint256) {
        return qplgmeStartTimestamp.add(qplgmeLength).sub(block.timestamp);
    }

    function startQPLGME() public onlyOwner() erisQPLGMEInactive() notHadQPLGME() {
        qplgmeActive = true;
        qplgmeStartTimestamp = block.timestamp;
        emit QPLGMEStarted( qplgmeActive, qplgmeStartTimestamp );
    }

    function quadraticPricewithAdditionalPayment( address buyer, uint additionalAmountPaid ) public view returns ( uint ) {
        return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[buyer].add( additionalAmountPaid ) ).mul(_erisToEthRatio).mul(1e9);
    }

    function erisForWeiPaid( uint256 payment ) public view returns ( uint256 ) {
        return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    }

    function _erisForWeiPaid( uint256 payment ) private view returns ( uint256 ) {
        return FinancialSafeMath.quadraticPricing( payment ).mul(_erisToEthRatio).mul(1e9);
    }

    function createPairOnUniswap() private {
        /*
        ***************** FOR TESTING ONLY *************************************************************
        */
        uniswapV2ErisWETHDEXPairAddress = address( _uniswapFactoryV2Factory.createPair( address(_testToken), address(this) ) );
        // _weth = IWETH(address(_uniswapV2Router.WETH()));
        // uniswapV2ErisWETHDEXPairAddress = address( uniswapFactoryV2Factory.createPair( address(_uniswapV2Router.WETH()), address(this) ) );
        _uniswapV2ErisWETHDEXPair = IUniswapV2Pair( uniswapV2ErisWETHDEXPairAddress );
    }

    function buyERIS( uint256 amount) public payable erisQPLGMEActive() {
        uint256 amountPaidInWEI = amount;
        _testToken.transferFrom( _msgSender(), address(this), amount);

        uin256 memory currentBuyersWeirPaidForEris_ = _weiPaidForErisByAddress[_msgSender()];
        _weiPaidForErisByAddress[_msgSender()] = _weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI);

        totalWeiPaidForEris = totalWeiPaidForEris.add(_weiPaidForErisByAddress[_msgSender()]).sub( currentBuyersWeirPaidForEris_ );

        _totalSupply = _totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[_msgSender()] ) );

        ethDonationToCharity = ethDonationToCharity.add( _weiPaidForErisByAddress[_msgSender()] / 10 ).sub( currentBuyersWeirPaidForEris_.div(10) );
    }

    function endQPLGME() public onlyOwner() {
        if( !hadQPLGME ) {
            _completeErisGME();
        }
        emit QPLGMEEnded( qplgmeActive, qplgmeEndTimestamp );
    }

    function collectErisFromQPLGME() public erisQPLGMEInactive() {
        if( !hadQPLGME ) {
            _completeErisGME();
        }

        if( _weiPaidForErisByAddress[_msgSender()] > 0 ){
            uint256 weiPaidForErisByAddress_ = _weiPaidForErisByAddress[_msgSender()];
            _weiPaidForErisByAddress[_msgSender()] = 0;
            _balances[_msgSender()] =  _erisForWeiPaid( weiPaidForErisByAddress_ );
        }
    }

    function _completeErisGME() private  {
        qplgmeEndTimestamp = block.timestamp;
        qplgmeActive = false;
        hadQPLGME = true;
        
        // _balances[charityAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
        _balances[charityAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
        _totalSupply = _totalSupply.add(_balances[charityAddress]);
        // ethDonationToCharity = _weth.balanceOf( address(this) ).div(10);
        ethDonationToCharity = _testToken.balanceOf( address(this) ).div(10);

        // erisDueToReserves = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );

        _fundReservesAndSetTotalSupply();
        _collectDonationToCharity();
        _depositInUniswap();
    }

    function _fundReservesAndSetTotalSupply() private {
        fundCharity();
        fundDev();
    }

    function fundDev() private {
        // _balances[devAddress] = _erisForWeiPaid( _weth.balanceOf( address( this ) ) );
        _balances[devAddress] = _erisForWeiPaid( _testToken.balanceOf( address( this ) ) );
        _totalSupply = _totalSupply.add(_balances[devAddress]);
    }

    function fundCharity() private {
    }

    function _collectDonationToCharity() private {
        require( ethDonationToCharity > 0 );
        ethDonationToCharity = 0;
        // _weth.transfer( charityAddress, _weth.balanceOf( address(this) ).div(10) );
        _testToken.transfer( charityAddress, _testToken.balanceOf( address(this) ).div(10) );
    }

    function _depositInUniswap() private {
        // totalWeiPaidForEris = _weth.balanceOf( address(this) );
        totalWeiPaidForEris = _testToken.balanceOf( address(this) );
        _balances[address(_uniswapV2ErisWETHDEXPair)] = FinancialSafeMath.bondingPrice( _totalSupply.div(totalWeiPaidForEris), _totalSupply ).mul(_erisToEthRatio).div(1e2);
        // _weth.transfer( address(_uniswapV2ErisWETHDEXPair), _weth.balanceOf( address(this) ) );
        _testToken.transfer( address(_uniswapV2ErisWETHDEXPair), _testToken.balanceOf( address(this) ) );
        _uniswapV2ErisWETHDEXPair.mint(address(this));
        _totalLPTokensMinted = _uniswapV2ErisWETHDEXPair.balanceOf(address(this));
        require(_totalLPTokensMinted != 0 , "No LP deposited");
        _lpPerETHUnit = _totalLPTokensMinted.mul(1e18).div(totalWeiPaidForEris);
        require(_lpPerETHUnit != 0 , "Eris:292:_depositInUniswap(): No LP deposited");
    }

    function erisDueToBuyerAtEndOfLGE( address buyer ) public view returns ( uint256 ){
        return FinancialSafeMath.quadraticPricing( _weiPaidForErisByAddress[ buyer ] ).mul(_erisToEthRatio).mul(1e9);
        //return _erisForWeiPaid( _weiPaidForErisByAddress[ buyer ] );
    }

    function withdrawPaidETHForfietAllERIS() public erisQPLGMEActive() {
        uint256 weiPaid = _weiPaidForErisByAddress[_msgSender()];
        _weiPaidForErisByAddress[_msgSender()] = 0 ;
        _balances[_msgSender()] = 0;
        totalWeiPaidForEris = totalWeiPaidForEris.sub( weiPaid );
        ethDonationToCharity = ethDonationToCharity.sub( weiPaid.div(10) );
        // _weth.withdraw( weiPaid );
        // _msgSender().transfer( weiPaid );
        _testToken.transfer( _msgSender(), weiPaid );
    }
}