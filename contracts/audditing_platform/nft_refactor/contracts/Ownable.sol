pragma solidity ^0.6.10;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Ownable {

    using Address for address;
    using SafeMath for uint256;

    address payable public owner;

    event TransferredOwnership(address _previous, address _next, uint256 _time, string _message);

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address payable _owner) public onlyOwner() {
        address previousOwner = owner;
        owner = _owner;

        // Inform everyone and use a user friendly message
        emit TransferredOwnership(previousOwner, owner, now, "Ownership has been transferred");
    }
}