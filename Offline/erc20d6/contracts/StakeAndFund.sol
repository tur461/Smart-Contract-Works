pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

contract StakeAndFund {
    address _owner;
    IERC20 _tokenContractAdress;
    uint8 public _rewardRate = 10; // 10%
    uint public _thresholdTime = 10 * 60 * 60 * 24 * 365; // 1 yr
    uint _totalStakeHolders;
    uint _fundLimit = 10 * 10 ** 18; // 10 eth

    mapping(address => uint) public _listOfNGOs;
    mapping(address => uint) public _stakedPerAddress;
    mapping(address => uint) public _depositTimePerAddress;

    event Staked(address, uint);
    event Received(address, uint);
    event Withdrawal(address, uint);
    
    
    constructor(address contractAddress_) public {
        _owner = msg.sender;
        _tokenContractAdress = IERC20(contractAddress_);
    }

    function setTokenAddress(address contractAddress_) public {
        require(_totalStakeHolders == 0);
        require(msg.sender == _owner, "must be owner");
        require(contractAddress_ != address(0), "Address can't be zero (0x0)");
        
        _tokenContractAdress = IERC20(contractAddress_);
    }
    
    function stake(uint tokens_) public returns (bool SUCCESS){
        require(_stakedPerAddress[msg.sender] == 0, "Already staked tokens");
        require(tokens_ > 0, "Provide non-zero tokens");
        
        
        _depositTimePerAddress[msg.sender] = block.timestamp;
        _stakedPerAddress[msg.sender] = tokens_;
        _totalStakeHolders += 1;

        _tokenContractAdress.transferFrom(msg.sender, address(this), tokens_); // this can revert
        
        emit Staked(msg.sender, tokens_);
        return true;
    }

    function withdraw() public returns (bool SUCCESS){
        
        require(_stakedPerAddress[msg.sender] > 0, "Not staked any token!");
        require((_depositTimePerAddress[msg.sender] - block.timestamp) * 1000 > _thresholdTime);
        
        uint rewarded = _stakedPerAddress[msg.sender]*(1/_rewardRate);
        
        _stakedPerAddress[msg.sender] = 0;
        _totalStakeHolders -= 1;        
        _tokenContractAdress.transfer(msg.sender, rewarded); // from: address(this)
        msg.sender.transfer(address(this), rewarded);
        
        emit Withdrawal(msg.sender, rewarded);
        
        return true;
    }

    function requestFund(address payable to_) public payable {

        require (_listOfNGOs[to_] == 0);
        uint bal = address(this).balance;
        require (bal > 0, "No funds available!.");
        
        if(bal < 10) _fundLimit = bal;
        _listOfNGOs[to_] = _fundLimit;
        bool sent = to_.send(_fundLimit);
        require(sent, "Failed to send Ether");
    }


    function depositEther() public payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}