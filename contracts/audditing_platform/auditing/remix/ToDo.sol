// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    // We need owner to be payable so this contract is basically the same + some improvements
    // double underscore so that we can use external/internal visibility (automatic getter blocks otherwise)
    address payable private __owner;

    modifier onlyOwner() {
        require(__owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    constructor() internal {
        __owner = _msgSender();
        emit OwnershipTransferred(address(0), __owner);  
    }

    function owner() external view returns (address payable) {
        return _owner();
    }

    function _owner() internal view returns (address payable) {
        return __owner;
    }

    function renounceOwnership() external onlyOwner() {
        address prevOwner = __owner;
        __owner = address(0);

        emit OwnershipTransferred(prevOwner, __owner);
    }

    function transferOwnership(address payable _newOwner) external onlyOwner() {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");

        address prevOwner = __owner;
        __owner = _newOwner;

        emit OwnershipTransferred(prevOwner, __owner);
    }
}

contract Auditable is Ownable {

    address public auditor;
    address public platform;

    // Indicates whether the audit has been completed or is in progress
    bool public audited;
    // Indicates whether the audit has been approved (true) or opposed (false)
    bool public approved;

    // A deployed contract has a creation hash, store it so that you can access the code 
    // post self destruct from an external location
    string public contractCreationHash;

    modifier isApproved() {
        require(approved, "Functionality blocked until contract is approved");
        _;
    }

    event SetAuditor(   address indexed _sender, address indexed _auditor);
    event SetPlatform(  address indexed _sender, address indexed _platform);

    event ApprovedAudit(address _auditor);
    event OpposedAudit( address _auditor);

    event CreationHashSet(string _hash);

    constructor(address _auditor, address _platform) Ownable() internal {
        _setAuditor(_auditor);
        _setPlatform(_platform);
    }

    function setContractCreationHash(string memory _hash) external onlyOwner() {
        // Prevent the owner from setting the hash post audit for safety
        require(!audited, "Contract has already been audited");

        // We do not want the deployer to change this as the auditor is approving/opposing
        // Auditor can check that this has been set at the beginning and move on
        require(bytes(contractCreationHash).length == 0, "Hash has already been set");

        contractCreationHash = _hash;

        emit CreationHashSet(contractCreationHash);
    }

    function setAuditor(address _auditor) external {
        _setAuditor(_auditor);
    }

    function setPlatform(address _platform) external {
        _setPlatform(_platform);
    }

    function _setAuditor(address _auditor) private {
        // If auditor bails then owner can change
        // If auditor loses contact with owner and cannot complete the audit then they can change
        require(_msgSender() == auditor || _msgSender() == _owner(), "Auditor and Owner only");

        // Do not spam events after the audit; easier to check final state if you cannot change it
        require(!audited, "Cannot change auditor post audit");

        auditor = _auditor;

        emit SetAuditor(_msgSender(), auditor);
    }

    function _setPlatform(address _platform) private {
        // If auditor bails then owner can change
        // If auditor loses contact with owner and cannot complete the audit then they can change
        require(_msgSender() == auditor || _msgSender() == _owner(), "Auditor and Owner only");

        // Do not spam events after the audit; easier to check final state if you cannot change it
        require(!audited, "Cannot change platform post audit");

        platform = _platform;

        emit SetPlatform(_msgSender(), platform);
    }

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

        // Inform the platform      
        (bool _success, ) = platform.call(abi.encodeWithSignature("completeAudit(address,address,bool,bytes)",  _msgSender(), address(this), approved, abi.encodePacked(_hash)));

        require(_success, "Unknown error, up the chain, when approving the audit");

        emit ApprovedAudit(_msgSender());
    }

    function opposeAudit(string memory _hash) external {
        // Only the auditor should be able to approve
        require(_msgSender() == auditor, "Auditor only");

        // Make sure that the hash has been set and that they match
        require(bytes(contractCreationHash).length != 0, "Hash has not been set");
        require(keccak256(abi.encodePacked(_hash)) == keccak256(abi.encodePacked(contractCreationHash)), "Hashes do not match");
        
        // Auditor cannot change their mind and approve/oppose multiple times
        require(!audited, "Cannot oppose an audited contract");

        // Switch to true to complete the audit and explicitly set approved to false (default is false)
        audited = true;
        approved = false;

        // Inform the platform      
        (bool _success, ) = platform.call(abi.encodeWithSignature("completeAudit(address,address,bool,bytes)", _msgSender(), address(this), approved, abi.encodePacked(_hash)));

        require(_success, "Unknown error, up the chain, when opposing the audit");

        emit OpposedAudit(_msgSender());
    }

    function nuke() external {
        require(_msgSender() == auditor || _msgSender() == _owner(), "Auditor and Owner only");
        require(audited, "Cannot nuke an unaudited contract");
        require(!approved, "Cannot nuke an approved contract");

        (bool _success, ) = platform.call(abi.encodeWithSignature("nukedContract(address,address)", _msgSender(), address(this), abi.encodePacked(_hash)));

        require(_success, "Unknown error, up the chain, when nuking the contract");

        selfdestruct(_owner());
    }
}

contract ToDo is Auditable {

    using SafeMath for uint256;

    modifier taskExists(uint256 _taskID) {
        require(0 < tasks[_msgSender()].length, "Task list is empty");
        require(_taskID <= tasks[_msgSender()].length, "Task does not exist");
        _;
    }

    struct Task {
        uint256 priority;
        bool completed;
        string task;
    }

    // keep your naughtiness to yourself
    mapping(address => Task[]) private tasks;

    event AddedTask(            address _creator, uint256 _taskID);
    event CompletedTask(        address _creator, uint256 _taskID);
    event RevertedTask(         address _creator, uint256 _taskID);
    event UpdatedDescription(   address _creator, uint256 _taskID);
    event UpdatedPriority(      address _creator, uint256 _taskID);

    constructor(address _auditor, address _platform) Auditable(_auditor, _platform) public {}

    function safeTaskID(uint256 _taskID) private pure returns (uint256) {
        // Cannot completely tailer to everyone because I can either start from the 0th indexed
        // so the user must know to start counting from 0 or alternatively start from 1
        // Tailor to majority starting at 1 by decrementing the number
        if (_taskID != 0) {
            _taskID = _taskID.sub(1);
        }
        return _taskID;
    }

    function viewTask(uint256 _taskID) external isApproved() taskExists(_taskID) view returns (uint256, bool, string memory) {
        _taskID = safeTaskID(_taskID);
        return 
        (
            tasks[_msgSender()][_taskID].priority,
            tasks[_msgSender()][_taskID].completed, 
            tasks[_msgSender()][_taskID].task
        );
    }

    function addTask(string calldata _task) external isApproved() {
        tasks[_msgSender()].push(Task({
            priority: tasks[_msgSender()].length + 1,
            completed: false, 
            task: _task
        }));

        emit AddedTask(_msgSender(), tasks[_msgSender()].length);
    }
    
    function changeTaskPriority(uint256 _taskID, uint256 _priority) external isApproved() taskExists(_taskID) {
        uint256 id = _taskID;
        _taskID = safeTaskID(_taskID);
        
        require(!tasks[_msgSender()][_taskID].completed, "Cannot edit completed task");
        require(tasks[_msgSender()][_taskID].priority != _priority, "New priority must be different");
        
        tasks[_msgSender()][_taskID].priority = _priority;

        emit UpdatedPriority(_msgSender(), id);
    }
    
    function changeTaskDescription(uint256 _taskID, string calldata _task) external isApproved() taskExists(_taskID) {
        uint256 id = _taskID;
        _taskID = safeTaskID(_taskID);
        
        require(!tasks[_msgSender()][_taskID].completed, "Cannot edit completed task");
        require(keccak256(abi.encodePacked(tasks[_msgSender()][_taskID].task)) != keccak256(abi.encodePacked(_task)), "New description must be different");
        
        tasks[_msgSender()][_taskID].task = _task;

        emit UpdatedDescription(_msgSender(), id);
    }
    
    function completeTask(uint256 _taskID) external isApproved() taskExists(_taskID) {
        uint256 id = _taskID;
        _taskID = safeTaskID(_taskID);
        
        require(!tasks[_msgSender()][_taskID].completed, "Task has already been completed");
        
        tasks[_msgSender()][_taskID].completed = true;

        emit CompletedTask(_msgSender(), id);
    }

    function undoTask(uint256 _taskID) external isApproved() taskExists(_taskID) {
        uint256 id = _taskID;
        _taskID = safeTaskID(_taskID);
        
        require(tasks[_msgSender()][_taskID].completed, "Task has not been completed");

        tasks[_msgSender()][_taskID].completed = false;

        emit RevertedTask(_msgSender(), id);
    }
    
    function taskCount() external isApproved() view returns (uint256) {
        return tasks[_msgSender()].length;
    }
    
    function completedTaskCount() external isApproved() view returns (uint256) {
        // loops are evil. if you add too many tasks then RIP you
        uint256 completed;
        
        for (uint256 _ID; _ID < tasks[_msgSender()].length; _ID++) {
            if (tasks[_msgSender()][_ID].completed) {
                completed = completed.add(1);
            }
        }
        
        return completed;
    }
    
    function incompleteTaskCount() external isApproved() view returns (uint256) {
        // loops are evil. if you add too many tasks then RIP you
        uint256 incomplete;
        
        for (uint256 _ID; _ID < tasks[_msgSender()].length; _ID++) {
            if (!tasks[_msgSender()][_ID].completed) {
                incomplete = incomplete.add(1);
            }
        }
        
        return incomplete;
    }

    function taskPriority(uint256 _taskID) external isApproved() taskExists(_taskID) view returns (uint256) {
        return tasks[_msgSender()][safeTaskID(_taskID)].priority;
    }

    function isTaskCompleted(uint256 _taskID) external isApproved() taskExists(_taskID) view returns (bool) {
        return tasks[_msgSender()][safeTaskID(_taskID)].completed;
    }
    
    function taskDescription(uint256 _taskID) external isApproved() taskExists(_taskID) view returns (string memory) {
        return tasks[_msgSender()][safeTaskID(_taskID)].task;
    }
}
