// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.0;

import "./Ownable.sol";

contract Pausable is Ownable {

    bool private _paused;

    modifier whenNotPaused() {
        require(!_paused, "Action is active");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Action is suspended");
        _;
    }

    event Paused(   address indexed _sender);
    event Unpaused( address indexed _sender);

    constructor () internal {}

    function paused() external view returns (bool) {
        return _paused;
    }

    function pause() external onlyOwner() whenNotPaused() {
        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() external onlyOwner() whenPaused() {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
