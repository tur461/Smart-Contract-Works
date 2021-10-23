const HDWalletProvider = require('truffle-hdwallet-provider');
require('dotenv').config();

const token = process.env.TOKEN;
const mnemonic = process.env.MNEMONIC;

module.exports = {
  
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
    rinkeby: {
      provider: _ => new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${token}`),
      network_id: 4,
      gas: 6700000,
      gasPrice: 10000000000, 
    }
    // ,
    // compilers: {
    //   solc: {
    //     version: "0.5.16",    // Fetch exact version from solc-bin (default: truffle's version)
    //     settings: {          // See the solidity docs for advice about optimization and evmVersion
    //      optimizer: {
    //        enabled: false
    //      }
    //     }
    //   }
    // }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    etherscan: 'Y6PMZSW9N93SV5ZHMTMXXX4FJRAVMEZ7KC',
  }
};
