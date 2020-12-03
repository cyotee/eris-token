// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Pausable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Datastore is Pausable {
    
    using SafeMath for uint256;

    // Daisy chain the data stores backwards to allow recursive backwards search.
    address public previousDatastore;

    string constant public version = "Demo: 1";
    
    bool public activeStore = true;

    // Completed audits
    event NewRecord(address indexed _auditor, address indexed _deployer, address _contract, string _hash, bool indexed _approved, uint256 _contractIndex);

    // Daisy chain stores
    event LinkedDataStore(address indexed _owner, address indexed _dataStore);
    
    constructor() Pausable() public {}

    /**
        @notice Check in the current data store if the _auditor address has ever been added
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev The check is for the record ever being added and not whether the _auditor address is currently a valid auditor
        @return Boolean value indicating if this address has ever been added as an auditor
    */
    function hasAuditorRecord(address _auditor) external view returns (bool) {
        return _hasAuditorRecord(_auditor);
    }

    /**
        @notice Check if the _auditor address is currently a valid auditor in this data store
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev This will return false in both occasions where an auditor is suspended or has never been added to this store
        @return Boolean value indicating if this address is currently a valid auditor
    */
    function isAuditor(address _auditor) external view returns (bool) {
        // Ambigious private call, call with caution or use with hasAuditorRecord()
        return _isAuditor(_auditor);
    }

    function searchAllStoresForIsAuditor(address _auditor) external view returns (bool) {
        // Check in all previous stores if the latest record of them being an auditor is set to true/false
        // This is likely to be expensive so it is better to check each store manually / individually
        return _recursiveIsAuditorSearch(_auditor, previousDatastore);
    }

    /**
        @notice Check the details on the _auditor in this current data store
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev Looping is a future problem therefore tell them the length and they can use the index to fetch the contract
        @return The current state of the auditor and the total number of approved contracts and the total number of opposed contracts
    */
    function auditorDetails(address _auditor) external view returns (bool, uint256, uint256) {
        return _auditorDetails(_auditor);
    }

    /**
        @notice Check the approved contract information for an auditor
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @param _index A number which should be less than or equal to the total number of approved contracts for the _auditor
        @return The audited contract information
    */
    function auditorApprovedContract(address _auditor, uint256 _index) external view returns (address, address, address, bool, bool, string memory) {
        uint256 _contractIndex = _auditorApprovedContract(_auditor, _index);
        return _contractDetails(_contractIndex);
    }

    /**
        @notice Check the opposed contract information for an auditor
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @param _index A number which should be less than or equal to the total number of opposed contracts for the _auditor
        @return The audited contract information
    */
    function auditorOpposedContract(address _auditor, uint256 _index) external view returns (address, address, address, bool, bool, string memory) {
        uint256 _contractIndex = _auditorOpposedContract(_auditor, _index);
        return _contractDetails(_contractIndex);
    }

    /**
        @notice Check in the current data store if the _contractHash address has been added
        @param _contractHash The address, intented to be a contract
        @dev There are two hash values, contract creation transaction and the actual contract hash, this is the contract hash
        @return Boolean value indicating if this address has been addede to the store
    */
    function hasContractRecord(address _contractHash) external view returns (bool) {
        return _hasContractRecord(_contractHash);
    }

    /**
        @notice Check in the current data store if the _creationHash address has been added
        @param _creationHash The address, intented to be a contract
        @dev There are two hash values, contract creation transaction and the actual contract hash, this is the creation hash
        @return Boolean value indicating if this address has been addede to the store
    */
    function hasContractCreationRecord(string memory _creationHash) external view returns (bool) {
        // TODO: can the parameter be an address type? Mapping is currently string
        return _hasCreationRecord(_creationHash);
    }

    /**
        @notice Check the contract details using the _contract address
        @param _contract Either the hash used to search for the contract or the transaction hash indicating the creation of the contract
        @return The data stored regarding the contract audit
    */
    function contractDetails(address _contract) external view returns (address, address, address, bool, bool, string memory) {
        return _contractDetails(_contract);
    }

    function searchAllStoresForContractDetails(address _contract) external view returns (address, address, address, bool, bool, string memory) {
        // Check in all previous stores if this contract has been recorded
        // This is likely to be expensive so it is better to check each store manually / individually
        return _contractDetailsRecursiveSearch(_contract, previousDatastore);
    }

    function contractDestructed(address _contract, address _initiator) external onlyOwner() {
        _contractDestructed(_contract, _initiator);
    }

    /**
        @notice Check in the current data store if the _deployer address has ever been added
        @param _deployer The address, intented to be a wallet (but may be a contract), which represents a deployer
        @return Boolean value indicating if this address has been added to the current store
    */
    function hasDeployerRecord(address _deployer) external view returns (bool) {
        return _hasDeployerRecord(_deployer);
    }

    /**
        @notice Check the details on the _deployer in this current data store
        @param _deployer The address, intented to be a wallet (but may be a contract), which represents a deployer
        @dev Looping is a future problem therefore tell them the length and they can use the index to fetch the contract
        @return The number of approved contracts and the total number of opposed contracts
    */
    function deployerDetails(address _deployer) external view returns (bool, uint256, uint256) {
        _deployerDetails(address _deployer);
    }

    /**
        @notice Add an auditor to the data store
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev Used to add a new address therefore should be used once per address. Intented as the initial save
    */
    function addAuditor(address _auditor) external onlyOwner() whenNotPaused() {
        require(activeStore, "Store has been deactivated");
        _addAuditor(_auditor);
    }

    /**
        @notice Revoke permissions from the auditor
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev After an auditor has been added one may decide that they are no longer fit and thus deactivate their audit writing permissions.
        Note that we are disabling them in the current store which prevents actions in the future stores therefore we never go back and change
        previous stores on the auditor
    */
    function suspendAuditor(address _auditor) external onlyOwner() {
        require(activeStore, "Store has been deactivated");
        _suspendAuditor(_auditor);
    }

    /**
        @notice Reinstate the permissions for the auditor that is currently suspended
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @dev Similar to the addition of the auditor but instead flip the isAuditor boolean back to true
    */
    function reinstateAuditor(address _auditor) external onlyOwner() whenNotPaused() {
        require(activeStore, "Store has been deactivated");
        _reinstateAuditor(_auditor);
    }

    function migrateAuditor(address _migrator, address _auditor) external onlyOwner() {
        _migrate(_migrator, _auditor);
    }

    /**
        @notice Write a new completed audit into the data store
        @param _auditor The address, intented to be a wallet, which represents an auditor
        @param _deployer The address, intented to be a wallet (but may be a contract), which represents a deployer
        @param _contract The hash used to search for the contract
        @param _approved Boolean indicating whether the contract has passed or failed the audit
        @param _txHash The hash depicting the transaction which created the contract
    */
    function completeAudit(address _auditor, address _deployer, address _contract, bool _approved, bytes calldata _txHash) external onlyOwner() whenNotPaused() {
        require(activeStore, "Store has been deactivated");

        // Must be a valid auditor in the current store to be able to write to the current store
        require(_hasAuditorRecord(_auditor), "No auditor record in the current store");
        require(_isAuditor(_auditor), "Auditor has been suspended");

        uint256 _contractIndex = _saveContract(_auditor, _contract, _deployer, _approved, string(_txHash));

        _addDeployer(_deployer);

        _saveContractIndexForAuditor(_approved, _contractIndex);
        _saveContractIndexForDeplyer(_approved, _contractIndex);

        emit NewRecord(_auditor, _deployer, _contract, _hash, _approved, _contractIndex);
    }

    function linkDataStore(address _dataStore) external onlyOwner() {
        require(activeStore, "Store has been deactivated");
        
        activeStore = false;
        previousDatastore = _dataStore;

        emit LinkedDataStore(_msgSender(), previousDatastore);
    }
}
