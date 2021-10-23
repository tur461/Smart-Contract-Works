pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

contract StakingE2D6 {
    address _owner;
    IERC20 _tokenContractAdress;
    uint8 public _rewardRate = 10; // 10%
    uint public _thresholdTime = 10 * 60; // 10 min
    uint _totalStaked;
    mapping(address => uint) public _stakedPerAddress;
    mapping(address => uint) public _depositTimePerAddress;

    event Staked(address o, uint t);
    event Withdrawal(address o, uint t);
    
    
    constructor(address contractAddress_) public {
        _owner = msg.sender;
        _tokenContractAdress = IERC20(contractAddress_);
    }

    function setTokenAddress(address contractAddress_) public {
        require(_totalStaked == 0);
        require(msg.sender == _owner, "must be owner");
        require(contractAddress_ != address(0), "Address can't be zero (0x0)");
        _tokenContractAdress = IERC20(contractAddress_);
    }
    
    function stake(uint tokens_) public returns (bool SUCCESS){
        require(_stakedPerAddress[msg.sender] == 0, "Already staked tokens");
        require(tokens_ > 0, "Provide non-zero tokens");
        
        
        _depositTimePerAddress[msg.sender] = block.timestamp;
        _stakedPerAddress[msg.sender] = tokens_;
        _totalStaked += 1;

        _tokenContractAdress.transferFrom(msg.sender, address(this), tokens_); // this can revert
        
        emit Staked(msg.sender, tokens_);
        return true;
    }

    function withdraw() public returns (bool SUCCESS){
        
        require(_stakedPerAddress[msg.sender] > 0, "Not staked any token!");
        require((_depositTimePerAddress[msg.sender] - block.timestamp) * 1000 > _thresholdTime);
        
        uint rewarded = _stakedPerAddress[msg.sender]*(1/_rewardRate);
        
        _stakedPerAddress[msg.sender] = 0;
        _totalStaked -= 1;        
        _tokenContractAdress.transfer(msg.sender, rewarded); // this can revert
        
        emit Withdrawal(msg.sender, rewarded);
        
        return true;
    }
}