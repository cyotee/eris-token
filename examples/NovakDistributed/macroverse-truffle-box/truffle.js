module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    // Make sure that your live network is called "live" to avoid trying to re-deploy the Macroverse contracts.
    live: {
      network_id: 1,
      gas: 4700000, // Knock down because it has to be les than block gas limit
      gasPrice: 4000000000 // Defaults to 100 gwei = 100 shannon = 100 billion, which is extremely high.
    }
  }
};
