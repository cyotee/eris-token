pragma solidity ^0.6.10;
import "./Ownable.sol";

contract Donations is Ownable {

    // the non-fungible token can be updated over time as newer versions are released
    address public NFT;

    // value used as a start/stop mechanic for donating
    bool public paused;

    event Donated(address _donator, uint256 _value, uint256 _time, string _message);
    event ChangedNFT(address _previous, address _next, uint256 _time, string _message);
    event PauseStatus(bool _status, address _contract, uint256 _time, string _message);
    event SelfDestructed(address _self, uint256 _time, string _message);

    constructor(address _NFT) Ownable() public {
        // launch the NFT with the platform
        setNFT(_NFT);

        // pause donations at the start until we are ready
        flipPauseState();
    }

    function donate() public payable {
        require(!paused, "Donations are currently paused");
        // Accept any donation (including 0) but ...
        // if donation >= 0.1 ether then mint the non-fungible token as a collectible
        // and as a thank you
        if (msg.value >= 100000000000000000) 
        {
            // Call the mint function of the current NFT contract address
            // keep in mind that you can keep donating but you will only ever have ONE
            // NFT in total (per NFT type). This should not mint additional tokens
            NFT.call(abi.encodeWithSignature("mint(address)", msg.sender));
        }

        // Transfer the value to the owner
        owner.transfer(msg.value);

        // Inform everyone and use a user friendly message
        emit Donated(msg.sender, msg.value, now, "A donation has been received");
    }

    function setNFT(address _NFT) public onlyOwner() {
        // Over time new iterations of (collectibles) NFTs shall be issued.

        // For user convenience it would be better to inform the user instead of just changing
        // the NFT. Exmaples include minimum time locks, total number of donations or a fund goal
        address previousNFT = NFT;
        NFT = _NFT;

        // Inform everyone and use a user friendly message
        emit ChangedNFT(previousNFT, NFT, now, "The NFT has been updated");
    }

    function flipPauseState() public onlyOwner() {
        // Change the boolean value of paused
        // true -> false || false -> true
        paused = paused ? false : true;

        // Set the message for the PausedStatus event based on the boolean value of paused
        string memory message = paused ? "Donations have been paused" : "Donations are open";

        // Inform everyone and use a user friendly message
        emit PauseStatus(paused, address(this), now, message);
    }

    function destroyContract() public onlyOwner() {
        // Inform everyone and use a user friendly message
        emit SelfDestructed(address(this), now, "Destructing the donation platform");
        
        selfdestruct(owner);
    }

}