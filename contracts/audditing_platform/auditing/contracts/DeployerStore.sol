// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract AuditorStore {
    
    using SafeMath for uint256;

    uint256 public activeDeployerCount;
    uint256 public blacklistedDeployerCount;

    struct Deployer {
        address    deployer;
        bool       blacklisted;
        uint256[]  approvedContracts;
        uint256[]  opposedContracts;
    }

    mapping(address => Deployer) public deployers;

    // State changes to auditors
    // TODO: Events for deployers
    // TODO: Ban list for deploying addresses? Address list linking one address to others since you can easily create a new wallet
    event AddedDeployer(     address indexed _owner, address indexed _deployer);
    event SuspendedDeployer( address indexed _owner, address indexed _deployer);
    event ReinstatedDeployer(address indexed _owner, address indexed _deployer);

    constructor() internal {}

    function _addDeployer(address _deployer) internal {
        // If this is a new deployer address then write them into the store
        if (!_hasDeployerRecord(_deployer)) {
            deployers[_deployer].deployer = _deployer;

            // Nice-to-have statistics
            activeDeployerCount = activeDeployerCount.add(1);

            // Which platform initiated the call on the _auditor
            emit AddedDeployer(_msgSender(), _deployer);
        }
    }

    function _suspendDeployer(address _deployer) internal {
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

    function _reinstateDeployer(address _deployer) internal {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(!_isAuditor(_auditor), "Auditor already has active status");

        auditors[_auditor].isAuditor = true;
        
        // Nice-to-have statistics
        activeAuditorCount = activeAuditorCount.add(1);
        suspendedAuditorCount = suspendedAuditorCount.sub(1);

        // Which platform initiated the call on the _auditor
        emit ReinstatedAuditor(_msgSender(), _auditor);
    }

    function _hasDeployerRecord(address _deployer) private view returns (bool) {
        return deployers[_deployer].deployer != address(0);
    }

    function _isBlacklisted(address _deployer) internal view returns (bool) {
        // This will return false in both cases where an auditor has not been added into this datastore
        // or if they have been added but suspended
        return deployers[_deployer].blacklisted;
    }

    function _deployerDetails(address _deployer) internal view returns (bool, uint256, uint256) {
        require(_hasDeployerRecord(_deployer), "No deployer record in the current store");

        return 
        (
            deployers[_deployer].blacklisted, 
            deployers[_deployer].approvedContracts.length, 
            deployers[_deployer].opposedContracts.length
        );
    }

    function _deployerApprovedContract(address _auditor, uint256 _index) internal view returns (uint256) {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(0 < auditors[_auditor].approvedContracts.length, "Approved list is empty");
        require(_index <= auditors[_auditor].approvedContracts.length, "Record does not exist");

        // Indexing from the number 0 therefore decrement if you must
        if (_index != 0) {
            _index = _index.sub(1);
        }

        return auditors[_auditor].approvedContracts[_index];
    }

    function _deployerOpposedContract(address _auditor, uint256 _index) external view returns (uint256) {
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(0 < auditors[_auditor].opposedContracts.length, "Opposed list is empty");
        require(_index <= auditors[_auditor].opposedContracts.length, "Record does not exist");

        // Indexing from the number 0 therefore decrement if you must
        if (_index != 0) {
            _index = _index.sub(1);
        }

        return auditors[_auditor].opposedContracts[_index];
    }

    function _saveContractIndexForDeplyer(bool _approved, uint256 _index) internal {
        if (_approved) {
            deployers[_deployer].approvedContracts.push(_index);
        } else {
            deployers[_deployer].opposedContracts.push(_index);
        }
    }
}
