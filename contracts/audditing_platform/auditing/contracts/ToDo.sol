// SPDX-License-Identifier: AGPL v3

pragma solidity ^0.6.10;

import "./Auditable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

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