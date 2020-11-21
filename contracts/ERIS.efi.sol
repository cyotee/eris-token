pragma solidity 0.7.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

library FinancialSafeMath {

    using SafeMath for uint256;

    function quadraticPricing( uint256 payment ) internal pure returns (uint256) {
        return payment.mul(2).sqrrt();
    }

    function bondingPrice( uint256 multiplier, uint256 supply ) internal pure returns (uint256) {
        return multiplier.mul( supply );
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = Context._msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == Context._msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    event FuckedWithUniswap( address indexed pairAddress, uint256 amount );
    event BanishedToTartarus( uint256 amountBanished );

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;
    uint256 public totalShares;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _nonce;
    uint256 public amountTransfered;
    uint8 private _transferFeePercentage = 10;
    
    IUniswapV2Pair internal _uniswapV2ErisWETHDEXPair;
    address public uniswapV2ErisWETHDEXPairAddress;

    constructor (string memory name_, string memory symbol_ ) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function sharesPerEris() public view returns (uint256) {
        return _sharesPerEris() ;
    }

    function _sharesPerEris() internal view returns (uint256) {
        return totalShares.div(_totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply.mul(_sharesPerEris());
    }

    function balanceOf(address account) public view override returns (uint256) {
        // if( account != uniswapV2ErisWETHDEXPairAddress ) {
        //     return _balances[account].mul(_sharesPerEris());
        // } else if( accpunt == uniswapV2ErisWETHDEXPairAddress ) {
        //     return _balances[account].div(_sharesPerEris());
        // }
        return _balances[account].mul(_sharesPerEris());
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(Context._msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(Context._msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, Context._msgSender(), _allowances[sender][Context._msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(Context._msgSender(), spender, _allowances[Context._msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(Context._msgSender(), spender, _allowances[Context._msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 transferFee = _getTransferFeeAmount( amount );
        uint256 chaosAmount = _getERSIChaosAmount( amount );
        uint256 transferFeeHolderShareAmount = transferFee.sub( chaosAmount );
        _chaos( chaosAmount );
        totalShares = totalShares.add(transferFeeHolderShareAmount);
        if( _balances[uniswapV2ErisWETHDEXPairAddress] > 0 ){
            _balances[uniswapV2ErisWETHDEXPairAddress] = _balances[uniswapV2ErisWETHDEXPairAddress].sub(transferFeeHolderShareAmount);
        }
        
        uint256 amountLeftToTransfer = amount.sub( transferFee );
        _balances[sender] = _balances[sender].sub( amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add( amountLeftToTransfer );
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        //_beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function _getBadRandomNumber00To99() private returns ( uint256 ) {

        _nonce = randomizeNonce();

        return uint(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    _nonce,
                    Context._msgSender(),
                    block.difficulty
                )
            )
        ) % 100;
    }

    function randomizeNonce() private view returns (uint256) {
        return uint(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    Context._msgSender(),
                    _nonce,
                    Context._msgSender(),
                    block.timestamp
                )
            )
        ) % 100;
    }

    function _getTransferFeeAmount( uint256 amountTransfered_ ) private view returns ( uint256 ) {
        return amountTransfered_.div(_transferFeePercentage);
    }

    function _getERSIChaosAmount( uint256 amountTransfered_ ) private returns ( uint256 ) {
        return FinancialSafeMath.bondingPrice( 55, _getTransferFeeAmount( amountTransfered_ ) ).div(1e2);
    }

    function _chaos(  uint256 amount ) private {

        uint256 chaos = _getBadRandomNumber00To99();

        if ( chaos > 50 ){
            _chaosBurn( amount );
        }

        if ( chaos <= 50){
            _transferToUniswapPair( amount );
        }

    }

    function _chaosBurn( uint256 amountToBurn ) internal {
        _totalSupply = _totalSupply.sub( amountToBurn );
        emit BanishedToTartarus(amountToBurn);
    }

    function _transferToUniswapPair( uint256 amountToTransfer ) private {
        _balances[address(_uniswapV2ErisWETHDEXPair)] = _balances[address(_uniswapV2ErisWETHDEXPair)].add(amountToTransfer);
        emit FuckedWithUniswap( address(_uniswapV2ErisWETHDEXPair), amountToTransfer );
    }
}

abstract contract ERC20Burnable is Context, ERC20 {
    
    using SafeMath for uint256;
    using Address for address;

    function burn(uint256 amount) public virtual {
        _burn(Context._msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, Context._msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, Context._msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

abstract contract Divine is ERC20Burnable, Ownable {
    
    using SafeMath for uint256;
    using Address for address;

    /*
    ***************** FOR TESTING ONLY *************************************************************
    */
    event TestTokenChanged( address indexed previousTestToken, address indexed newTestTokenAddress );
    event TransferFeeShareCollected( address indexed recipient, uint256 amount );

    /*
    Main net, Ropsten, Rinkerby
    0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    */
    IUniswapV2Factory internal _uniswapFactoryV2Factory;
    /*
    Main net, Ropsten, Rinkerby
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    */
    IUniswapV2Router02 internal _uniswapV2Router;

    // IWETH private _weth;
    IERC20 internal _testToken;
    
    constructor(
        string memory name_, 
        string memory symbol_,
        address uniswapV2FactoryAddress_,
        address uniswapV2RouterAddress_
    ) ERC20( name_, symbol_) Ownable() {

        // _uniswapFactoryV2Factory = IUniswapV2Factory(address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f));
        _uniswapFactoryV2Factory = IUniswapV2Factory(address(uniswapV2FactoryAddress_));
        // _uniswapV2Router = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
        _uniswapV2Router = IUniswapV2Router02(address(uniswapV2RouterAddress_));
        // charityAddress = payable( 0x666F20A36BFbbC4bB98ad5D59747d1EbE175E02C );
        // createPairOnUniswap();
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

    function setTestToken( address testToken_ ) public onlyOwner() {
        _testToken = IERC20(testToken_);
        createPairOnUniswap();
    }
}

contract Eris is Divine {
    
    using SafeMath for uint256;
    using Address for address;

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

    constructor()
        Divine( 
            "ERIS", 
            "ERIS", 
            0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f, 
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        ) 
    {

        // uint256 totalSupply_ = 30000 * 1e18;
        // _mint( Context._msgSender(), totalSupply_ );
        // totalShares = _totalSupply;

        devAddress = Context._msgSender();
        charityAddress = payable( 0x666F20A36BFbbC4bB98ad5D59747d1EbE175E02C );
    }

    // function changeCharityAddress( address newCharityAddress_ ) public onlyOwner() {
    //     charityAddress = payable(newCharityAddress_);
    // }

    // function changeDevAddress( address newDevAddress_ ) public onlyOwner() {
    //     devAddress = payable(newDevAddress_);
    // }

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

    // function buyERIS() public payable erisQPLGMEActive {
    //     uint256 amountPaidInWEI = msg.value;
    //     _weth.deposit{value: amountPaidInWEI}();
    //     totalWeiPaidForEris = totalWeiPaidForEris.add( amountPaidInWEI );
    //     if( _weiPaidForErisByAddress[Context._msgSender()] > 0 ){
    //         totalSupply = totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()] ) );
    //     } else if( _weiPaidForErisByAddress[Context._msgSender()] == 0 ) {
    //         totalSupply = totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add( amountPaidInWEI ) ) );
    //     }
    //     _weiPaidForErisByAddress[Context._msgSender()] = _weiPaidForErisByAddress[Context._msgSender()].add( amountPaidInWEI );
    //     ethDonationToCharity = ethDonationToCharity.add( amountPaidInWEI.div(10) );
    // }

    // function buyERIS( uint256 amount) public payable erisQPLGMEActive() {
    //     uint256 amountPaidInWEI = amount;
    //     _testToken.transferFrom( Context._msgSender(), address(this), amount);

    //     uin256 memory currentBuyersWeirPaidForEris_ = _weiPaidForErisByAddress[Context._msgSender()];
    //     _weiPaidForErisByAddress[Context._msgSender()] = _weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI);

    //     totalWeiPaidForEris = totalWeiPaidForEris.add(_weiPaidForErisByAddress[Context._msgSender()]).sub( currentBuyersWeirPaidForEris_ );

    //     _totalSupply = _totalSupply.add( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()].add(amountPaidInWEI)) ).sub( _erisForWeiPaid(_weiPaidForErisByAddress[Context._msgSender()] ) );

    //     ethDonationToCharity = ethDonationToCharity.add( _weiPaidForErisByAddress[Context._msgSender()] / 10 ).sub( currentBuyersWeirPaidForEris_.div(10) );
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

    //     if( _weiPaidForErisByAddress[Context._msgSender()] > 0 ){
    //         uint256 weiPaidForErisByAddress_ = _weiPaidForErisByAddress[Context._msgSender()];
    //         _weiPaidForErisByAddress[Context._msgSender()] = 0;
    //         _balances[Context._msgSender()] =  _erisForWeiPaid( weiPaidForErisByAddress_ );
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
    //     uint256 weiPaid = _weiPaidForErisByAddress[Context._msgSender()];
    //     _weiPaidForErisByAddress[Context._msgSender()] = 0 ;
    //     _balances[Context._msgSender()] = 0;
    //     totalWeiPaidForEris = totalWeiPaidForEris.sub( weiPaid );
    //     ethDonationToCharity = ethDonationToCharity.sub( weiPaid.div(10) );
    //     // _weth.withdraw( weiPaid );
    //     // Context._msgSender().transfer( weiPaid );
    //     _testToken.transfer( Context._msgSender(), weiPaid );
    // }
}