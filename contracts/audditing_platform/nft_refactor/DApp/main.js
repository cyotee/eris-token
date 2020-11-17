let web3 = new Web3(Web3.givenProvider);
let contractInstance;

$(document).ready(() => {
    window.ethereum.enable().then((accounts) => {
        contractInstance = new web3.eth.Contract(abi, "0x962a7195Cf19AE7d495c02669Beb948275581930", {from: accounts[0]});
        console.log(contractInstance);
    });

    $("#donate-btn").click(donate);
    $("#check-audit-btn").click(auditStatus);
});

function donate() {
    const donation = $("#donate-input").val();
    const config = {value: web3.utils.toWei(donation, "ether")}

    contractInstance.methods.donate().send(config)
    .on("transactionHash", (hash) => {              console.log("Transaction Hash: " + hash);})
    .on("confirmation", (confirmationNumber) => {   console.log("Confirmation Number: " + confirmationNumber);})
    .on("receipt", (receipt) => {                   console.log("Receipt: " + receipt);})
}

function auditStatus() {
    contractInstance.methods.audited().call()
    .then((audited) => {$("#audit_output").text("Audit has " + audited ? "" : "NOT " + "been completed")})
}






