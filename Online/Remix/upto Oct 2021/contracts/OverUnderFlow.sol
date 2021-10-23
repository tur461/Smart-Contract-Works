pragma solidity ^0.8.0;

contract OverUnderFlow {
    address owner;
    mapping(address => uint) balances;
    
    constructor() {
        owner = msg.sender;
    }
    
    function transfer(address to_, uint val_) public returns(bool) {
        if(balances[msg.sender] - val_ > 0 ){
            balances[msg.sender] -= val_;
            balances[to_] += val_;
            return true;
        }
        else
            return false;
    }
    
    function balanceOf(address of_) public view returns(uint) {
        return balances[of_];
    }
    
    function deposit(address to_, uint am_) public {
        require(msg.sender == owner, "only owner allowed to deposit");
        balances[to_] = am_;
    }
}