pragma solidity >=0.4.22 <0.9.0;


contract StakingE2D6 {
    address owner;
    uint8 public RewardRate = 10; // 10%
    uint public Threshold_Time = 10 * 60; // 10 min

    mapping(address => uint) public StakedPerAddress;
    mapping(address => uint) public DepositTimePerAddress;

    event Stacked(address, uint);
    event Withdrawal(address, uint);
    
    
    constructor(address _e2d6Contract) public {
        owner = msg.sender;
    }
    
    function stake(uint tokens) external returns (bool SUCCESS){
        require(tokens > 0);
        DepositTimePerAddress[msg.sender] = block.timestamp;
        StakedPerAddress[msg.sender] += tokens;
        
    }

    function withdraw() external returns (uint){
        require((DepositTimePerAddress[msg.sender] - block.timestamp) * 1000 > Threshold_Time);
        
        uint t = StakedPerAddress[msg.sender];
        
        StakedPerAddress[msg.sender] = 0;
        return t*(1/RewardRate);
    }
}