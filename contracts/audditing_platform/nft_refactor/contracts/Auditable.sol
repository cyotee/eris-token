pragma solidity ^0.6.10;
import "./Ownable.sol";

contract Auditable is Ownable {

    address public auditor;
    address public auditedContract;

    // Indicates whether the audit has been completed and approved (true) or not (false)
    bool public audited;

    modifier isAudited() {
        require(audited, "Not audited");
        _;
    }

    // emitted when the contract has been audited and approved/opposed
    event ApprovedAudit(address _auditor, address _contract, uint256 _time, string _message);
    event OpposedAudit(address _auditor, address _contract, uint256 _time, string _message);
    event SetAuditor(address _previousAuditor, address _newAuditor, address _contract, uint256 _time, string _message);

    constructor(address _auditor, address _auditedContract) Ownable() public {
        setAuditor(_auditor);
        auditedContract = _auditedContract;
    }

    function setAuditor(address _auditor) public {
        require(msg.sender == auditor || msg.sender == owner, "Auditor and Owner only");
        require(!audited, "Cannot change auditor post audit");
        
        address previousAuditor = auditor;
        auditor = _auditor;
        
        // Inform everyone and use a user friendly message
        emit SetAuditor(previousAuditor, auditor, auditedContract, now, "Auditor has been set");
    }

    // The auditor is approving the contract by switching the audit bool to true. 
    // This unlocks contract functionality via the isAudited modifier
    function approveAudit() public {
        require(msg.sender == auditor, "Auditor only");
        require(!audited, "Contract has already been approved");

        audited = true;

        // Inform everyone and use a user friendly message
        emit ApprovedAudit(auditor, auditedContract, now, "Contract approved, functionality unlocked");
    }

    // The auditor is opposing the audit by switching the bool to false
    function opposeAudit() public {
        require(msg.sender == auditor, "Auditor only");
        require(!audited, "Cannot destroy an approved contract");
        
        // The default (unset) bool is set to false but do not rely on that; set to false to be sure.
        audited = false;

        // Inform everyone and use a user friendly message
        emit OpposedAudit(auditor, auditedContract, now, "Contract has failed the audit");
    }
}




