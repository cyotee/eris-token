// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.4;

import "hardhat/console.sol";

import "./abstract/Divine.sol";
import "./dependencies/holyzeppelin/contracts/math/SafeMath.sol";
// import "./libraries/datatypes/primitives/Address.sol";
// import "../libraries/datatypes/collections/EnumerableSet.sol";

contract ErisToken is Divine {

    using SafeMath for uint256;

    uint8 public transferFeePercentageX100;
    
    constructor () Divine() {
        console.log("ERIS::constructor: Instantiating ERIS");
        transferFeePercentageX100 = 100;
        uint256 amountToMint_ = 50000 * 1e18;
        console.log("Minting %s ERIS.", amountToMint_ );
        _mint(Context._msgSender(), amountToMint_  );
        console.log("Minted %s ERIS.", totalSupply());
        console.log("ERIS::constructor: Instantiated ERIS");
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override(ERC20) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 amountAfterTransferFee_ = _deductTransferFee( amount );
        console.log("Transfer amount after fee is %s.", amountAfterTransferFee_);
        uint256 transferFeeAmount_ = _calculateTransferFeeAmount( amount );
        console.log("Transfer fee amount of %s.", transferFeeAmount_);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountAfterTransferFee_);
        emit Transfer(sender, recipient, amountAfterTransferFee_);
    }

    function _deductTransferFee( uint256 amountTrasferred_ ) internal returns (uint256) {
        return amountTrasferred_.substractPercentage(transferFeePercentageX100);
    }

    function _calculateTransferFeeAmount( uint256 amount_ ) internal returns ( uint256 ) {
        return amount_.percentageAmount( transferFeePercentageX100 );
    }
}