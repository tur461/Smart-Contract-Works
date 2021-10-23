pragma solidity ^0.8.0;

contract InfLoopTest {
    event BeingFucked(string);
    constructor(){
        uint256 i = 0;
        for(; ;++i)
            emit BeingFucked("Fucked");
    }
}