require('dotenv').config();
const Web3 = require("web3");

const rinkebyUrl = process.env.INFURA;
const metaMaskUrl = process.env.MMASK;
const web3 = new Web3(new Web3.providers.HttpProvider(rinkebyUrl));

// window.addEventListener('load', () => {
//     // Wait for loading completion to avoid race conditions with web3 injection timing.
//      if (window.ethereum) {
//        const web3 = new Web3(window.ethereum);
//        try {
//          // Request account access if needed
//          await window.ethereum.enable();
//          // Acccounts now exposed
//          return web3;
//        } catch (error) {
//          console.error(error);
//        }
//      }
//      // Legacy dapp browsers...
//      else if (window.web3) {
//        // Use Mist/MetaMask's provider.
//        const web3 = window.web3;
//        console.log('Injected web3 detected.');
//        return web3;
//      }
//      // Fallback to localhost; use dev console port by default...
//      else {
//        const provider = new Web3.providers.HttpProvider('http://127.0.0.1:9545');
//        const web3 = new Web3(provider);
//        console.log('No web3 instance injected, using Local web3.');
//        return web3;
//      }
//    });


function getBalance(address){
    web3.eth.getBalance(address, (err, result) => {
        if (err)
        console.log(err)
        else
        console.log(`Balance for Address ${address}: ` + web3.utils.fromWei(result, "ether") + " ETH");
    });
}

function getGasPrice(){
    web3.eth.getGasPrice().then(p => console.log('Gas Price is: ' + web3.utils.fromWei(p, "wei") + " ETH"));
}

function getGasEstimate(address, abi, meth_name, params){
    // console.log('abi:', abi);
    
    let cInstance = new web3.eth.Contract(abi, address),
        meth = cInstance.methods[meth_name];
    console.log(cInstance.methods);
    if(meth)
        meth(...params)
        .estimateGas({
            from: '0xF19250A3320bE69B80daf65D057aE05Bb12F0919',
            gas: '5000000',
            // value: '1599'
            // gas: '1000000009'
        })
        .then(o => {
            console.log('Estimated gas for '+ meth_name + ' is: ' + o);
        })
        .catch(e => console.log('error:', e));
    else
        console.log('Method name: ' + meth_name + " doesn't exist.");

}

module.exports = {
    getBalance,
    getGasPrice,
    getGasEstimate,
}