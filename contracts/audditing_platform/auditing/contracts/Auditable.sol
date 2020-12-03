// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Ownable.sol";

contract Auditable is Ownable {

    /**
        @notice the address of the auditor who is auditing the contract that inherits from this contract
    */
    address public auditor;

    /**
        @notice the destination which the status of the audit is transmitted to
    */
    address public platform;

    /**
        
    */
    address public immutable deployer;

    /**
        @notice Indicates whether the audit has been completed or is in progress
        @dev Audit is completed when the bool is set to true otherwise the default is false (in progress)
    */
    bool public audited;
    
    /**
        @notice Indicates whether the audit has been approved or opposed
        @dev Consider this bool only after "audited" is true. Approved is true and Opposed (default) if false
    */
    bool public approved;

    /**
        @notice A deployed contract has a creation hash, store it so that you can access the code post self destruct
        @dev When a contract is deployed the first transaction is the contract creation - use that hash
    */
    string public contractCreationHash;

    /**
        @notice Modifier used to block or allow method functionality based on the approval / opposition of the audit
        @dev Use this on every function
    */
    modifier isApproved() {
        require(approved, "Functionality blocked until contract is approved");
        _;
    }

    /**
        @notice Event tracking who set the auditor and who the auditor is
        @dev Index the sender and the auditor for easier searching
    */
    event SetAuditor(address indexed _sender, address indexed _auditor);
    
    /**
        @notice Event tracking who set the platform and which platform was set
        @dev Index the sender and the platform for easier searching
    */
    event SetPlatform(address indexed _sender, address indexed _platform);
    
    /**
        @notice Event tracking the status of the audit and who the auditor is
    */
    event ApprovedAudit(address _auditor);

    /**
        @notice Event tracking the status of the audit and who the auditor is
    */
    event OpposedAudit( address _auditor);
    
    /**
        @notice A contract has a transaction which is the contract creation.
        @dev The contract creation hash allows one to view the bytecode of the contract even after it has self destructed
    */
    event CreationHashSet(string _hash);

    /**
        @notice The inheriting contract must tell us who the audit and platform are to be able to perform an audit
        @param _auditor an address of a person who may or may not actually be an auditor
        @param _platform an address of a contract which may or may not be a valid platform
        @dev Ownable() with our implementation to be cleaner and internal because it is not meant to be public, inherit the methods and variables
    */
    constructor(address _auditor, address _platform) Ownable() internal {
        deployer = _owner();
        _setAuditor(_auditor);
        _setPlatform(_platform);
    }

    /**
        @notice Method used to set the contract creation has before the audit is completed
        @dev After deploying this is the first thing that must be done by the owner and the owner only gets 1 attempt to prevent race conditions with the auditor
        @param _hash The transaction hash representing the contract creation
    */
    function setContractCreationHash(string memory _hash) external onlyOwner() {
        // Prevent the owner from setting the hash post audit for safety
        require(!audited, "Contract has already been audited");

        // We do not want the deployer to change this as the auditor is approving/opposing
        // Auditor can check that this has been set at the beginning and move on
        require(bytes(contractCreationHash).length == 0, "Hash has already been set");

        contractCreationHash = _hash;

        emit CreationHashSet(contractCreationHash);
    }

    /**
        @notice Used to change the auditor by either the owner or auditor prior to the completion of the audit
        @param _auditor an address indicating who the new auditor will be (may be a contract)
    */
    function setAuditor(address _auditor) external {
        _setAuditor(_auditor);
    }

    /**
        @notice Used to change the platform by either the owner or auditor prior to the completion of the audit
        @param _platform an address indicating a contract which will be the new platform (middle man)
    */
    function setPlatform(address _platform) external {
        _setPlatform(_platform);
    }

    /**
        @dev private implementation because they should not be messing around with this in their contract
        @param _auditor an address indicating who the new auditor will be (may be a contract)
    */
    function _setAuditor(address _auditor) private {
        // If auditor bails then owner can change
        // If auditor loses contact with owner and cannot complete the audit then they can change
        require(_msgSender() == auditor || _msgSender() == _owner(), "Auditor and Owner only");

        // Do not spam events after the audit; easier to check final state if you cannot change it
        require(!audited, "Cannot change auditor post audit");

        auditor = _auditor;

        emit SetAuditor(_msgSender(), auditor);
    }

    /**
        @dev private implementation because they should not be messing around with this in their contract
        @param _platform an address indicating a contract which will be the new platform (middle man)
    */
    function _setPlatform(address _platform) private {
        // If auditor bails then owner can change
        // If auditor loses contact with owner and cannot complete the audit then they can change
        require(_msgSender() == auditor || _msgSender() == _owner(), "Auditor and Owner only");

        // Do not spam events after the audit; easier to check final state if you cannot change it
        require(!audited, "Cannot change platform post audit");

        platform = _platform;

        emit SetPlatform(_msgSender(), platform);
    }

    /**
        @notice Auditor is in favor of the contract therefore they approve it and transmit to the platform
        @param _hash The contract creation hash that the owner set
        @dev The auditor and owner may conspire to use a different hash therefore the platform would yeet them after the fact - if they find out
    */
    function approveAudit(string memory _hash) external {
        // Only the auditor should be able to approve
        require(_msgSender() == auditor, "Auditor only");

        // Make sure that the hash has been set and that they match
        require(bytes(contractCreationHash).length != 0, "Hash has not been set");
        require(keccak256(abi.encodePacked(_hash)) == keccak256(abi.encodePacked(contractCreationHash)), "Hashes do not match");
        
        // Auditor cannot change their mind and approve/oppose multiple times
        require(!audited, "Contract has already been audited");

        // Switch to true to complete audit and approve
        audited = true;
        approved = true;

        // TODO: think about the owner being sent and transfer of ownership and how that affects the store
        // Inform the platform      
        (bool _success, ) = platform.call(abi.encodeWithSignature("completeAudit(address,address,address,bool,bytes)", _msgSender(), deployer, address(this), approved, abi.encodePacked(_hash)));

        require(_success, "Unknown error, up the chain, when approving the audit");

        emit ApprovedAudit(_msgSender());
    }

    /**
        @notice Auditor is against the contract therefore they oppose it and transmit to the platform
        @param _hash The contract creation hash that the owner set
        @dev The auditor and owner may conspire to use a different hash therefore the platform would yeet them after the fact - if they find out
    */
    function opposeAudit(string memory _hash) external {
        address _initiator = _msgSender();
        require(_initiator == auditor, "Auditor only");

        // Make sure that the hash has been set and that they match
        // Design Flaw: Auditor and Deployer may colllude and use a different hash - cannot fix with code..?
        // TODO: Can we somehow query the blockchain with address(this) and find the hash? It's an event so probably not
        //       unless we have a client do it and call back into the contract
        require(bytes(contractCreationHash).length != 0, "Hash has not been set");
        require(keccak256(abi.encodePacked(_hash)) == keccak256(abi.encodePacked(contractCreationHash)), "Hashes do not match");
        
        // Auditor cannot change their mind and approve/oppose multiple times
        require(!audited, "Cannot oppose an audited contract");

        // Switch to true to complete the audit and explicitly set approved to false (default is false)
        audited = true;
        approved = false;

        // TODO: think about the owner being sent and transfer of ownership and how that affects the store
        // Inform the platform      
        (bool _success, ) = platform.call(abi.encodeWithSignature("completeAudit(address,address,address,bool,bytes)", _initiator, deployer, address(this), approved, abi.encodePacked(_hash)));

        require(_success, "Unknown error, up the chain, when opposing the audit");

        emit OpposedAudit(_initiator);
    }

    /**
        @notice Allows the auditor or the owner to clean up after themselves and return a portion of the deployment funds if the contract is opposed
    */
    function destruct() external {
        // TODO: change deployer to owner?
        
        address _initiator = _msgSender();

        require(_initiator == auditor || _initiator == deployer, "Auditor and Deployer only");
        require(audited, "Cannot destruct an unaudited contract");
        require(!approved, "Cannot destruct an approved contract");

        (bool _success, ) = platform.call(abi.encodeWithSignature("contractDestructed(address)", _initiator));

        require(_success, "Unknown error, up the chain, when destructing the contract");

        selfdestruct(deployer);
    }
}