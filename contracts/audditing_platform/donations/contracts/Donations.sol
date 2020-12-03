// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Pausable.sol";

contract Donations is Pausable {

    // The non-fungible, non-transferable token can be updated over time as newer versions are released
    address public NFT;

    event Donated(address indexed _donator, uint256 _value);
    event ChangedNFT(address indexed _NFT);
    event InitializedNFT(address _NFT);
    event SelfDestructed(address _owner, address _self);

    constructor(address _NFT) Pausable() public {
        NFT = _NFT;
        emit InitializedNFT(NFT);
    }

    function donate() external payable whenNotPaused() {
        // Accept any donation (including 0) but ...
        // if donation >= 0.1 ether then mint the non-fungible token as a collectible / thank you
        if (msg.value >= 100000000000000000) 
        {
            // Call the mint function of the current NFT contract
            // keep in mind that you can keep donating but you will only ever receive ONE
            // NFT in total (per NFT type). This should not mint additional tokens
            NFT.call(abi.encodeWithSignature("mint(address)", _msgSender()));
        }

        // Transfer the value to the owner
        _owner().transfer(msg.value);

        emit Donated(_msgSender(), msg.value);
    }

    function setNFT(address _NFT) external onlyOwner() {
        // Over time new iterations of (collectibles) NFTs shall be issued.

        // For user convenience it would be better to inform the user instead of just changing
        // the NFT. Exmaples include minimum time locks, total number of donations or a fund goal
        NFT = _NFT;

        emit ChangedNFT(NFT);
    }

    function destroyContract() external onlyOwner() {
        emit SelfDestructed(_msgSender(), address(this));

        // Everything should be fine at this point but just to be extra safe use the _owner()
        selfdestruct(_owner());
    }
}