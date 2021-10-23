pragma solidity ^0.8.0;

contract TokenDEMO {
    uint8 _decimals = 6;
    uint _totalSupply = 10000;
    string _name = "Demo token";
    string _symbol = "DEM";

    constructor(string memory n_, string memory s_){
        _name = n_;
        _symbol = s_;
    }

    function totalSupply() public view returns(uint){
        return _totalSupply;
    }

    function name() public view returns(string memory){
        return _name;
    }

    function symbol() public view returns(string memory){
        return _symbol;
    }
}