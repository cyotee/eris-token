// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract AuditorStore {
    
    using SafeMath for uint256;

    uint256 public activeAuditorCount;
    uint256 public suspendedAuditorCount;

    struct Auditor {
        address    auditor;
        bool       isAuditor;
        uint256[]  approvedContracts;
        uint256[]  opposedContracts;
    }

    mapping(address => Auditor)  public auditors;

    // State changes to auditors
    event AddedAuditor(     address indexed _owner, address indexed _auditor);
    event SuspendedAuditor( address indexed _owner, address indexed _auditor);
    event ReinstatedAuditor(address indexed _owner, address indexed _auditor);

    // Auditor migration
    event AcceptedMigration(address indexed _migrator, address indexed _auditor);

    constructor() internal {}

    function _addAuditor(address _auditor) internal {
        require(!_hasAuditorRecord(_auditor), "Auditor record already exists");

        auditors[_auditor].isAuditor = true;
        auditors[_auditor].auditor = _auditor;
        
        // Nice-to-have statistics
        activeAuditorCount = activeAuditorCount.add(1);

        // Which platform initiated the call on the _auditor
        emit AddedAuditor(_msgSender(), _auditor);
    }

    function _suspendAuditor(address _auditor) internal {
        if (_hasAuditorRecord(_auditor)) {
            if (!_isAuditor(_auditor)) {
                revert("Auditor has already been suspended");
            }
            // Nice-to-have statistics
            activeAuditorCount = activeAuditorCount.sub(1);
        } else {
            // If the previous store has been disabled when they were an auditor then write them into the (new) current store and disable
            // their permissions for writing into this store and onwards. They should not be able to write back into the previous store anyway
            auditors[_auditor].auditor = _auditor;
        }

        auditors[_auditor].isAuditor = false;
        
        // Nice-to-have statistics
        suspendedAuditorCount = suspendedAuditorCount.add(1);

        // Which platform initiated the call on the _auditor
        emit SuspendedAuditor(_msgSender(), _auditor);
    }

    function _reinstateAuditor(address _auditor) internal {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(!_isAuditor(_auditor), "Auditor already has active status");

        auditors[_auditor].isAuditor = true;
        
        // Nice-to-have statistics
        activeAuditorCount = activeAuditorCount.add(1);
        suspendedAuditorCount = suspendedAuditorCount.sub(1);

        // Which platform initiated the call on the _auditor
        emit ReinstatedAuditor(_msgSender(), _auditor);
    }

    function _hasAuditorRecord(address _auditor) internal view returns (bool) {
        return auditors[_auditor].auditor != address(0);
    }

    function _isAuditor(address _auditor) internal view returns (bool) {
        // This will return false in both cases where an auditor has not been added into this datastore
        // or if they have been added but suspended
        return auditors[_auditor].isAuditor;
    }

    function _auditorDetails(address _auditor) internal view returns (bool, uint256, uint256) {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");

        return 
        (
            auditors[_auditor].isAuditor, 
            auditors[_auditor].approvedContracts.length, 
            auditors[_auditor].opposedContracts.length
        );
    }

    function _auditorApprovedContract(address _auditor, uint256 _index) internal view returns (uint256) {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(0 < auditors[_auditor].approvedContracts.length, "Approved list is empty");
        require(_index <= auditors[_auditor].approvedContracts.length, "Record does not exist");

        // Indexing from the number 0 therefore decrement if you must
        if (_index != 0) {
            _index = _index.sub(1);
        }

        return auditors[_auditor].approvedContracts[_index];
    }

    function _auditorOpposedContract(address _auditor, uint256 _index) internal view returns (uint256) {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(0 < auditors[_auditor].opposedContracts.length, "Opposed list is empty");
        require(_index <= auditors[_auditor].opposedContracts.length, "Record does not exist");

        // Indexing from the number 0 therefore decrement if you must
        if (_index != 0) {
            _index = _index.sub(1);
        }

        return auditors[_auditor].opposedContracts[_index];
    }

    function _migrate(address _migrator, address _auditor) internal onlyOwner() {
        // Auditor should not exist to mitigate event spamming or possible neglectful changes to 
        // _recursiveAuditorSearch(address) which may allow them to switch their suspended status to active
        require(!_hasAuditorRecord(_auditor), "Already in data store");
        
        // Call the private method to begin the search
        // Also, do not shadow the function name
        bool isAnAuditor = _recursiveAuditorSearch(_auditor);

        // The latest found record indicates that the auditor is active / not been suspended
        if (isAnAuditor) {
            // We can migrate them to the current store
            // Do not rewrite previous audits into each new datastore as that will eventually become too expensive
            auditors[_auditor].isAuditor = true;
            auditors[_auditor].auditor = _auditor;

            activeAuditorCount = activeAuditorCount.add(1);

            emit AcceptedMigration(_migrator, _auditor);
        } else {
            revert("Auditor is either suspended or has never been in the system");
        }
    }

    function _saveContractIndexForAuditor(bool _approved, uint256 _index) internal {
        if (_approved) {
            auditors[_auditor].approvedContracts.push(_index);
        } else {
            auditors[_auditor].opposedContracts.push(_index);
        }
    }

    function _recursiveAuditorSearch(address _auditor, address _previousDatastore) private view returns (bool) {
        // Technically not needed as default is set to false but lets be explicit
        // Also, do not shadow the function name
        bool isAnAuditor = false;

        if (_hasAuditorRecord(_auditor)) {
            if (_isAuditor(_auditor)) {
                isAnAuditor = true;
            }
        } else if (_previousDatastore != address(0)) {
            (bool success, bytes memory data) = _previousDatastore.staticcall(abi.encodeWithSignature("searchAllStoresForIsAuditor(address)", _auditor));
            
            require(success, "Unknown error when recursing in datastore");

            isAnAuditor = abi.decode(data, (bool));
        } else {
            revert("No auditor record in any data store");
        }

        return isAnAuditor;
    }

}
