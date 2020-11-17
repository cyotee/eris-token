// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Token is Ownable, ERC721 {

    using SafeMath for uint256;

    // Used to issue unique tokens
    uint256 public tokenID;

    // One token per donator, keep track of donators to prevent minting more than once
    mapping(address => bool) public donators;

    event MintedToken(address indexed _donator, uint256 indexed _tokenId);
    event UpdatedMetaData(uint256 indexed _tokenId, string _metaData);
    event TransferAttempted(address indexed _from, address indexed _to, uint256 indexed _tokenId, string _message);

    constructor() Ownable() ERC721("Word", "WORD") public {}

    function mint(address _donator) external payable onlyOwner() {
        // Do not revert. They should be able to keep donating but only ever receive 1 token
        if (donators[_donator]) {
            return;
        }

        string memory _metaData =  string(abi.encodePacked(
            '{',
            '"name": ' , '"Donation Token: Word",',
            '"description": ', '"Thank you for donating!",',
            '"image": ', '"https://ipfs.io://ipfs/QmSZUL7Ea21osUUUESX6nPuUSSTF6RniyoJGBaa2ZY7Vjd",',
            '"tokenID": ', '"', tokenID, '",',
            '}'
            ));

        // Mint token and send to the _donator
        _safeMint(_donator, tokenID);
        _setTokenURI(tokenID, _metaData);

        uint256 ID = tokenID;

        // Increment the token ID for the next mint
        tokenID = tokenID.add(1);

        // One token per donator
        donators[_donator] = true;

        emit MintedToken(_donator, ID);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        emit TransferAttempted(from, to, tokenId, "The NFT is a non-fungible, non-transferable token");
    }

    function updateMetadata(uint256 _tokenID, string memory _metaData) external onlyOwner() {
        _setTokenURI(_tokenID, _metaData);

        emit UpdatedMetaData(_tokenID, _metaData);
    }
}