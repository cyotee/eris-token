// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AuditNFT is Ownable, ERC721 {

    using SafeMath for uint256;

    // Used to issue unique tokens
    uint256 public tokenID;

    event MintedToken(address _recipient, uint256 _tokenId);
    event TransferAttempted(address _from, address _to, uint256 _tokenId, string _message);

    constructor() Ownable() ERC721("Audit Archive NFT", "Audit Archive") public {}

    function mint(address _auditorAddr, address _contract, bool _approved, bytes calldata _hash) external onlyOwner() {

        // Address types must be converted manually otherwise conversions will not be in human readable form later
        string memory _auditor = addressToString(_auditorAddr);
        string memory _address = addressToString(_contract);
        string memory _metaData;

        string memory approved = _approved ? 'true' : 'false';

        _metaData =  string(abi.encodePacked(
            '{',
            '"name": ' , '"The Church of the Chain Incorporated Audit Archive NFT",',
            '"description": ', '"A record of the audit for this contract provided to auditors from The Church of the Chain Incorporated",',
            '"image": ', '"https://ipfs.io/ipfs/QmSZUL7Ea21osUUUESX6nPuUSSTF6RniyoJGBaa2ZY7Vjd",',
            '"auditor": ', '"', _auditor, '",',
            '"contract": ', '"', _address, '",',
            '"approved": ', approved, ',',
            '"deploymentHash": ', '"', string(_hash), '",',
            '}'
            ));

        // Mint token and send to the _recipient
        _safeMint(_auditorAddr, tokenID);
        _setTokenURI(tokenID, _metaData);

        uint256 ID = tokenID;

        // Increment the token ID for the next mint
        tokenID = tokenID.add(1);

        emit MintedToken(_auditorAddr, ID);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        emit TransferAttempted(from, to, tokenId, "The NFT is a non-fungible, non-transferable token");
    }

    function addressToString(address _address) private pure returns (string memory) {
        // utility function found on stackoverflow
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