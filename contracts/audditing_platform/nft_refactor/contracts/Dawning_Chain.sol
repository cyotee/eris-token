pragma solidity ^0.6.10;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Ownable.sol";

contract Dawning_Chain is Ownable, ERC721 {

    string public tokenDetails = '{ "name": "Donations Coin", "description": "Thank you for donating!", "image": "https://ipfs.io://ipfs/QmSZUL7Ea21osUUUESX6nPuUSSTF6RniyoJGBaa2ZY7Vjd" }';

    // Used to issue unique tokens
    uint256 public tokenID;

    // One token per donator, keep track of donators to prevent minting more than once
    mapping(address => bool) public donators;

    event MintedToken(address _donator, uint256 _tokenId, uint256 _time, string _message);
    event UpdatedMetaData(uint256 _tokenId, uint256 _time, string _message);
    event TransferAttempted(address _from, address _to, uint256 _tokenId, uint256 _time, string _message);

    constructor() Ownable() ERC721("The Church of the Chain incorporated inaugural donation NFT", "DAWNCHAIN") public {}

    function mint(address _donator) public payable onlyOwner() {
        if (donators[_donator]) {
            return;
        }

        // Mint token and send to the donator
        _safeMint(_donator, tokenID, '');
        _setTokenURI(tokenID, tokenDetails);

        // Inform everyone and use a user friendly message
        emit MintedToken(_donator, tokenID, now, "Token has been minted");

        // Increment the token ID for 
        tokenID = tokenID.add(1);
        donators[_donator] = true;
    }

    function updateMetadata(uint256 _tokenID, string memory _metaData) public onlyOwner() {
        _setTokenURI(_tokenID, _metaData);
        // Inform everyone and use a user friendly message
        emit UpdatedMetaData(_tokenID, now, "Updated token metadata");
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        // Inform everyone and use a user friendly message
        emit TransferAttempted(from, to, tokenId, now, "The NFT is a non-fungible, non-transferable token");
    }
}