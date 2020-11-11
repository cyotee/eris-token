// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity 0.7.4;

import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IWETH.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Counters.sol";

contract ERIS {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    address private _owner;

    Counters.Counter private nonce;

    string public _name = "ERIS";
    string public _symbol = "ERIS";
    uint8 private constant _decimals = 18;

    uint256 public _totalErisSupply;

    uint256 public _contractStartTimestamp;

    IUniswapV2Router02 public _uniswapRouterV2 = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    IUniswapV2Factory public _uniswapFactory = IUniswapV2Factory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f));
    IUniswapV2Pair public _erisWETHPair;
    address public _erisWETHPairAddress;

    uint256 public _ethDonationToCharity;
    uint256 public _totalETHPaidForEris;
    uint256 public _totalLPTokensMinted;
    uint256 public _lpPerETHUnit;
    uint256 public _totalErisDueToBuyersAtEndOfLGE;

    mapping ( address => uint256 ) public _ethPaidForErisByAddress;

    mapping ( address => uint256 ) private _erisBalances;
    mapping (address => mapping (address => uint256)) private _erisAllowances;
    
    address payable public _charityDonationAddress = payable(address(0xf28dCDF515E69da11EBd264163b09b1b30DC9dC8));

    bool public _erisGMEActive = true;

    uint8 private _erisToEthRatio = 5;
    uint8 private _devErisToEthRatio = 2;
    uint8 private _transferFeeShareCurveMultiplier = 7;

    uint256 private _totalTransferFeeShares;
    uint256 private _totalTransferFeeErisReleased;

    mapping(address => uint256) private _transferFeeShares;
    mapping(address => uint256) private _transferFeeErisReleased;
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier erisGMEActive() {
        //require( _contractStartTimestamp.add(2 days) > block.timestamp );
        require( _contractStartTimestamp.add(1 hours) > block.timestamp );
        _;
    }

    modifier erisGMEInactive() {
        //require( !(_contractStartTimestamp.add(2 days) > block.timestamp ));
        require( !(_contractStartTimestamp.add(1 hours) > block.timestamp ));
        _;
    }

    constructor() {

        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);

        _contractStartTimestamp = block.timestamp;

        createPairOnUniswap();
    }
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalErisSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _erisBalances[account];
    }

    function _approve(address holder, address spender, uint256 amount) private{
        require(holder != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _erisAllowances[holder][spender] = amount;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _erisAllowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _erisAllowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function allowance(address holder, address spender) public view returns (uint256) {
        return _erisAllowances[holder][spender];
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function createPairOnUniswap() private {
        _erisWETHPairAddress = _uniswapFactory.createPair(address(_uniswapRouterV2.WETH()),address(this));
        _erisWETHPair = IUniswapV2Pair(_erisWETHPairAddress);
    }

    function getSecondsLeftInLiquidityGenerationEvent() public view erisGMEActive returns (uint256) {
        return _contractStartTimestamp.add(2 days).sub(block.timestamp);
    }

    /*
    Original sqrrt function logic
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint z = x.add(1).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    */
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint z = x.add(1).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = x.div(z).add(z).div(2);
        }
    }

    function quadraticPricing( uint256 payment ) public pure returns (uint256) {
        return sqrt( ( payment * 2 ) );
    }

    function currentQuadraticPriceForAddress( address buyer ) public view returns ( uint256 ) {
        return quadraticPricing( _ethPaidForErisByAddress[buyer] );
    }

    function quadraticPricewithAdditionalPayment( address buyer, uint additionalAmountPaid ) public view returns ( uint ) {
        return quadraticPricing( _ethPaidForErisByAddress[buyer].add( additionalAmountPaid ) );
    }

    function erisDueAtEndOfLGE( address buyer ) public view returns ( uint256 ){
        return quadraticPricing( _ethPaidForErisByAddress[ buyer ] );
    }

    function assignTransferFeeShares() private {
        _totalTransferFeeShares = _totalTransferFeeShares.sub(_transferFeeShares[_msgSender()]);
        _transferFeeShares[_msgSender()] = _erisBalances[_msgSender()];
        _totalTransferFeeShares = _totalTransferFeeShares.add(_transferFeeShares[_msgSender()]);
    }

    function buyEris() public payable erisGMEActive {

        uint amountPaid = msg.value;

        uint amountDonated = amountPaid.div(10);
        amountDonated = amountPaid.div(1e18);

        _ethDonationToCharity = _ethDonationToCharity.add( amountDonated );

        uint amountAfterDonation = amountPaid.sub( amountDonated );
        
        _totalETHPaidForEris = _totalETHPaidForEris.sub( _ethPaidForErisByAddress[_msgSender()] );

        _ethPaidForErisByAddress[_msgSender()] = _ethPaidForErisByAddress[_msgSender()].add( amountAfterDonation );

        _totalETHPaidForEris = _totalETHPaidForEris.add( _ethPaidForErisByAddress[_msgSender()] );

        _totalErisDueToBuyersAtEndOfLGE = _totalErisDueToBuyersAtEndOfLGE.sub( _erisBalances[_msgSender()] );

        _erisBalances[_msgSender()] = quadraticPricing( _ethPaidForErisByAddress[_msgSender()] ).mul(_erisToEthRatio);

        assignTransferFeeShares();

        _totalErisDueToBuyersAtEndOfLGE = _totalErisDueToBuyersAtEndOfLGE.add(_erisBalances[_msgSender()]);
    }

    fallback () external payable {
        buyEris();
    }

    receive() external payable {
        buyEris();
    }

    function collectDonationToCharity() private {
        require( _ethDonationToCharity > 0 );

        _ethDonationToCharity = 0;
        
        uint256 amountToDonate = address(this).balance;
        amountToDonate = amountToDonate.div(10);

        _charityDonationAddress.transfer( amountToDonate );
    }

    function bondingPrice( uint256 multiplier, uint256 supply ) private pure returns (uint256) {
        return multiplier * supply;
    }

    function fundBuyersBalances() private {
        _totalErisSupply = _totalErisSupply.add(_totalErisDueToBuyersAtEndOfLGE);
    }

    function fundUniswapDeposit() private {
        uint256 ethBalance = address( this ).balance;
        ethBalance = ethBalance.div(1e18);
        _erisBalances[address( this )] = bondingPrice(
            ethBalance.div(_totalErisDueToBuyersAtEndOfLGE),
            _totalErisDueToBuyersAtEndOfLGE
        ).mul(_erisToEthRatio);

        _totalErisSupply = _totalErisSupply.add( _erisBalances[address( this )]);
    }

    function fundCharityBalance() private {
        uint256 ethBalance = address( this ).balance;
        ethBalance = ethBalance.div(1e18);
        _erisBalances[_charityDonationAddress] = bondingPrice(
            ethBalance.div(_totalErisDueToBuyersAtEndOfLGE),
            _totalErisDueToBuyersAtEndOfLGE
        ).mul(_erisToEthRatio);

        _totalErisSupply = _totalErisSupply.add( _erisBalances[address( this )] );
    }

    function generateEris() private {
        fundBuyersBalances();
        fundUniswapDeposit();
        fundCharityBalance();
    }
    
    function depositInUniswap() private {

        _totalETHPaidForEris = address(this).balance;

        IUniswapV2Pair pair = IUniswapV2Pair(_erisWETHPair);
        
        address WETH = _uniswapRouterV2.WETH();

        IWETH(WETH).deposit{value : _totalETHPaidForEris}();

        require(address(this).balance == 0 , "Transfer Failed");

        IWETH(WETH).transfer(address(pair),_totalETHPaidForEris);

        _erisBalances[address(pair)] = _erisBalances[address(this)];

        _erisBalances[address(this)] = 0;

        pair.mint(address(this));

        _totalLPTokensMinted = pair.balanceOf(address(this));
        
        require(_totalLPTokensMinted != 0 , "No LP deposited");

        _lpPerETHUnit = _totalLPTokensMinted.mul(1e18).div(_totalETHPaidForEris);
        
        require(_lpPerETHUnit != 0 , "No LP deposited");

        _erisGMEActive = false;
    }

    function completeErisGME() public onlyOwner erisGMEInactive {
        collectDonationToCharity();
        generateEris();
        depositInUniswap();
    }

    function _depositTransferFeeShare() private {
        require(_transferFeeShares[_msgSender()] > 0, "Account has no shares");

        uint256 totalReceived = _erisBalances[address( this )].add( _totalTransferFeeErisReleased );
        uint256 payment = totalReceived
            .mul(_transferFeeShares[_msgSender()])
            .div(_totalTransferFeeShares)
            .sub(_transferFeeErisReleased[_msgSender()]);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _transferFeeErisReleased[_msgSender()] = _transferFeeErisReleased[_msgSender()].add(payment);
        _totalTransferFeeErisReleased = _totalTransferFeeErisReleased.add(payment);

        _erisBalances[_msgSender()] = _erisBalances[_msgSender()].add(payment);
    }

    function getRandomNumber() private view returns (uint) {
        
        nonce.increment;

        return uint(
            keccak256(
                abi.encodePacked(
                    nonce.current(),
                    _msgSender(),
                    block.difficulty
                )
            )
        ) % 100;
    }

    function _burn( uint256 amountToBurn ) private {
        _totalErisSupply = _totalErisSupply.sub( amountToBurn );
    }

    function _transferToUniswapPair( uint256 amountToTransfer ) private {
        _erisBalances[_erisWETHPairAddress] = _erisBalances[_erisWETHPairAddress].add(amountToTransfer);
    }

    function _chaos(  uint256 amount ) private {

        uint256 chaos = getRandomNumber();

        if ( chaos > 50 ){
            _burn( amount );
        }

        if ( chaos <= 50){
            _transferToUniswapPair( amount );
        }

    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 transferFee = amount / 10;

        uint256 transferFeeShareAmount = bondingPrice(
            _transferFeeShareCurveMultiplier / 10,
            transferFee
        );

        uint256 chaosAmount = transferFee.sub(transferFeeShareAmount);

        _erisBalances[address( this )] = transferFeeShareAmount;

        _depositTransferFeeShare();

        _chaos( chaosAmount );

        _erisBalances[sender] = _erisBalances[sender].sub(amount.sub(transferFee), "ERC20: transfer amount exceeds balance");
        _erisBalances[recipient] = _erisBalances[recipient].add(amount.sub(transferFee));
    }

    function transfer(address recipient, uint256 amount) public erisGMEInactive returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public erisGMEInactive returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _erisAllowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
}