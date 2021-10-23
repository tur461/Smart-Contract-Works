require('dotenv').config();

const { 
    clArgs, 
    Addresses, 
} = require("./constants");
const { 
    getBalance, 
    getGasPrice,
    getGasEstimate,
} = require('./web3Functions');
const {
    getAbi, 
    getAddress, 
    getMethodName,
    getMethParams,
} = require('./utils');

const cla = process.argv.slice(2);
// console.log(cla);

let addressList = Object.values(Addresses).map((v,i) => { return {[i]:v} });

for(let i=0, a, stop=!1; i<cla.length && !stop; ++i){
    switch(cla[i]){
        case clArgs.BALANCE:
            a = getAddress(cla, addressList);
            if(a) getBalance(a)
            else {
                console.log('address missing.');
                stop = !0;
            }
            break;
        case clArgs.LIST_ADDRESS:
            console.log('Address:\n', addressList);
            break;
        case clArgs.GAS_PRICE:
            getGasPrice();
            break;
        case clArgs.CONTRACT_GE: 
            a = getAddress(cla, addressList); 
            let abi = getAbi(),
                mn = getMethodName(cla);
            if(!abi || !abi.length){
                console.log('ABI content not available.');
                return;
            }
            if(a && mn) getGasEstimate(a, abi, mn, getMethParams(cla))
            else{
                console.log('insufficient arguments');
                stop = !0;
            }
            break;
    }
}
console.log('\n');

