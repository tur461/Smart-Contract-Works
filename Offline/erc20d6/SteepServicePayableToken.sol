pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract SteepServicePayableToken is ERC20 {
    constructor(string memory n_, string memory s_) ERC20(n_, s_) {}
    
    function mint(address a_, uint256 amnt_) public {
        _mint(a_, amnt_);
    }
}