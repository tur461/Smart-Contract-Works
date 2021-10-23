const { clArgs, ABIPaths } = require('./constants');
const fs = require('fs');
const path = require('path');
const abiPaths = [
    ABIPaths.FISTContract,
    ABIPaths.FSContract
]
const contractAbiPath = abiPaths[0];

function getAddress(ar, al){
    for(let i=0; i<ar.length; ++i)
        if((ar[i] === clArgs.ADDRESS) &&
            ar[i+1] < al.length)
               return al.filter(a => !!a[ar[i+1]])[0][ar[i+1]];
}

function getMethodName(ar){
    for(let i=0; i<ar.length; ++i)
        if(ar[i] === clArgs.METHOD_NAME)
               return ar[i+1];
}

function getMethParams(ar){
    let p='';
    for(let i=0; i<ar.length; ++i)
        if(ar[i] === clArgs.METHOD_PARAM)
            p = ar[i+1];
    if(!p) { 
        console.log('params not provided');
        return [];
    }
    return p.split(',');
}

function getAbi(){
    let fp = path.join(__dirname, contractAbiPath);
    // console.log(fs.readFileSync(fp, 'utf8'));
    return JSON.parse(fs.readFileSync(fp, 'utf8'));
}

module.exports = {
    getAbi,
    getAddress,
    getMethodName,
    getMethParams,

}