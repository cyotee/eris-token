const ToDo = artifacts.require("ToDo");
const truffleAssert = require("truffle-assertions");

contract("ToDo", async (accounts) => {

    let owner;
    let auditor;
    let platform;
    let contractCreationHash;
    const task1 = "Remember to breathe";
    const task2 = "Underwear can be a pocket";

    before(() => {
        owner = accounts[0];
        auditor = accounts[1];
        platform = accounts[2];
        contractCreationHash = accounts[3];
    });

    beforeEach(async () => {
        todo = await ToDo.new(_auditor = auditor, _platform = platform, {from: owner});
    });

    describe("# constructor()", () => {

        it("Sets the auditor", async () => {
            assert.strictEqual(auditor, await todo.auditor());
        });

        it("Sets the todo", async () => {
            assert.strictEqual(platform, await todo.platform());
        });

    })

    describe("# addTask()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.addTask(_task = task1, {from: owner}));
        });

        it("Adds a task", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            initialTaskCount = await todo.taskCount();

            await todo.addTask(_task = task1, {from: owner});

            postTaskCount = await todo.taskCount();

            assert.strictEqual(0, initialTaskCount.toNumber());
            assert.strictEqual(1, postTaskCount.toNumber());
       });

        it("Emits the event AddedTask", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            const transaction = await todo.addTask(_task = task1, {from: owner});

            assert.strictEqual("AddedTask", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._creator);
            assert.strictEqual(1, transaction.logs[0].args._taskID.toNumber());
       });

    })

    describe("# viewTask()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.viewTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.viewTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.viewTask(_taskID = 5, {from: owner}));
       });

        it("Returns task data", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            const task = await todo.viewTask(_taskID = 1, {from: owner});

            assert.strictEqual(1, task[0].toNumber());
            assert.strictEqual(false, task[1]);
            assert.strictEqual(task1, task[2]);
       });

    })

    describe("# changeTaskPriority()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.changeTaskPriority(_taskID = 1, _priority = 2, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.changeTaskPriority(_taskID = 1, _priority = 2, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.changeTaskPriority(_taskID = 5, _priority = 2, {from: owner}));
       });

       it("Reverts if task is completed", async () => {
           await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            truffleAssert.reverts(todo.changeTaskPriority(_taskID = 1, _priority = 2, {from: owner}));
        });

        it("Reverts if priority is the same", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});
 
            truffleAssert.reverts(todo.changeTaskPriority(_taskID = 1, _priority = 1, {from: owner}));
        });

        it("Changes priority", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});

            const initialPriority = await todo.taskPriority(1);
 
            await todo.changeTaskPriority(_taskID = 1, _priority = 5, {from: owner});

            const postPriority = await todo.taskPriority(1);

            assert.strictEqual(1, initialPriority.toNumber());
            assert.strictEqual(5, postPriority.toNumber());
        });

        it("Emits the event UpdatedPriority", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            const transaction = await todo.changeTaskPriority(_taskID = 1, _priority = 5, {from: owner});

            assert.strictEqual("UpdatedPriority", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._creator);
            assert.strictEqual(1, transaction.logs[0].args._taskID.toNumber());
       });

    })

    describe("# changeTaskDescription()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.changeTaskDescription(_taskID = 1, _task = task2, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.changeTaskDescription(_taskID = 1, _task = task2, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.changeTaskDescription(_taskID = 5, _task = task2, {from: owner}));
       });

       it("Reverts if task is completed", async () => {
           await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            truffleAssert.reverts(todo.changeTaskDescription(_taskID = 1, _task = task2, {from: owner}));
        });

        it("Reverts if description is the same", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});
 
            truffleAssert.reverts(todo.changeTaskDescription(_taskID = 1, _task = task1, {from: owner}));
        });

        it("Changes description", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});

            const initialDescription = await todo.taskDescription(1);
 
            await todo.changeTaskDescription(_taskID = 1, _task = task2, {from: owner});

            const postDescription = await todo.taskDescription(1);

            assert.strictEqual(task1, initialDescription);
            assert.strictEqual(task2, postDescription);
            assert.notStrictEqual(initialDescription, postDescription);
        });

        it("Emits the event UpdatedDescription", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            const transaction = await todo.changeTaskDescription(_taskID = 1, _task = task2, {from: owner});

            assert.strictEqual("UpdatedDescription", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._creator);
            assert.strictEqual(1, transaction.logs[0].args._taskID.toNumber());
       });

    })

    describe("# completeTask()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.completeTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.completeTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.completeTask(_taskID = 5, {from: owner}));
       });

       it("Reverts if task is completed", async () => {
           await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
           await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

           await todo.addTask(_task = task1, {from: owner});
           await todo.completeTask(_taskID = 1, {from: owner});

           truffleAssert.reverts(todo.completeTask(_taskID = 1, {from: owner}));
        });

        it("Completes task by setting bool to true", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});

            const initialCompletion = await todo.isTaskCompleted(1);
 
            await todo.completeTask(_taskID = 1, {from: owner});

            const postCompletion = await todo.isTaskCompleted(1);

            assert.isFalse(initialCompletion);
            assert.isTrue(postCompletion);
        });

        it("Emits the event CompletedTask", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            const transaction = await todo.completeTask(_taskID = 1, {from: owner});

            assert.strictEqual("CompletedTask", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._creator);
            assert.strictEqual(1, transaction.logs[0].args._taskID.toNumber());
       });

    })

    describe("# undoTask()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.undoTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.undoTask(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.undoTask(_taskID = 5, {from: owner}));
       });

       it("Reverts if task is incompleted", async () => {
           await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            truffleAssert.reverts(todo.undoTask(_taskID = 1, {from: owner}));
        });

        it("Reverts task by setting bool back to false", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});
 
            await todo.addTask(_task = task1, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            const initialCompletion = await todo.isTaskCompleted(1);

            await todo.undoTask(_taskID = 1, {from: owner});

            const postCompletion = await todo.isTaskCompleted(1);

            assert.isTrue(initialCompletion);
            assert.isFalse(postCompletion);
        });

        it("Emits the event RevertedTask", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            const transaction = await todo.undoTask(_taskID = 1, {from: owner});

            assert.strictEqual("RevertedTask", transaction.logs[0].event);
            assert.strictEqual(1, transaction.logs.length);
            assert.strictEqual(owner, transaction.logs[0].args._creator);
            assert.strictEqual(1, transaction.logs[0].args._taskID.toNumber());
       });

    })

    describe("# taskCount()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.taskCount({from: owner}));
        });

        it("Returns the number of tasks", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            const count = await todo.taskCount();

            assert.strictEqual(2, count.toNumber());
        });

    })

    describe("# completedTaskCount()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.completedTaskCount({from: owner}));
        });

        it("Returns the number of completed tasks", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            const count = await todo.completedTaskCount();

            assert.strictEqual(1, count.toNumber());
        });

    })

    describe("# incompleteTaskCount()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.incompleteTaskCount({from: owner}));
        });

        it("Returns the number of completed tasks", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            const count = await todo.incompleteTaskCount();

            assert.strictEqual(1, count.toNumber());
        });

    })

    describe("# taskPriority()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.taskPriority(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.taskPriority(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.taskPriority(_taskID = 5, {from: owner}));
        });

        it("Returns the priority", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            const priority = await todo.taskPriority(_taskID = 1, {from: owner});

            assert.strictEqual(1, priority.toNumber());
        });

    })

    describe("# isTaskCompleted()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.isTaskCompleted(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.isTaskCompleted(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.isTaskCompleted(_taskID = 5, {from: owner}));
        });

        it("Returns true for completed task", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.completeTask(_taskID = 1, {from: owner});

            const completed = await todo.isTaskCompleted(_taskID = 1, {from: owner});

            assert.isTrue(completed);
        });

        it("Returns false for incomplete task", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});

            const completed = await todo.isTaskCompleted(_taskID = 1, {from: owner});

            assert.isFalse(completed);
        });

    })

    describe("# taskDescription()", () => {

        it("Reverts before approved audit", async () => {
            truffleAssert.reverts(todo.taskDescription(_taskID = 1, {from: owner}));
        });

        it("Reverts if task list is empty", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            truffleAssert.reverts(todo.taskDescription(_taskID = 1, {from: owner}));
        });

        it("Reverts if index of task is out of bounds", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            truffleAssert.reverts(todo.taskDescription(_taskID = 5, {from: owner}));
        });

        it("Returns the description", async () => {
            await todo.setContractCreationHash(_hash = contractCreationHash, {from: owner});
            await todo.approveAudit(_hash = contractCreationHash, {from: auditor});

            await todo.addTask(_task = task1, {from: owner});
            await todo.addTask(_task = task2, {from: owner});

            const description = await todo.taskDescription(_taskID = 1, {from: owner});
            const description2 = await todo.taskDescription(_taskID = 2, {from: owner});

            assert.strictEqual(task1, description);
            assert.strictEqual(task2, description2);
        });
    })
})