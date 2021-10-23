pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns(bool);
    function balanceOf(address guy) external view returns (uint256);
}

interface IUniswap {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
        
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function WETH() external pure returns (address);
}

contract MyDefiV2{
    address _owner;
    address _uniswap;
    address _diaToken;
    
    constructor(address uniswap_, address dia_) public {
        _owner = msg.sender;
        _uniswap = uniswap_;
        _diaToken = dia_;
    }
    
    
    // function for frontend to pay in either ether or DIA
    function pay(uint256 paymentInDia_) public payable {
        if(msg.value > 0) eth2dia(paymentInDia_);
        // this contract need to be approved by msg.sender
        // user must pay interms of DIA if not paid in ether
        else require(IERC20(_diaToken).transferFrom(msg.sender, address(this), paymentInDia_), "tranferFrom failed!");
    }

    function eth2dia(
        uint256 paymentInDia_
    ) public payable {
        uint deadline = block.timestamp + 15;
        address[] memory path = new address[](2);
        path[0] = IUniswap(_uniswap).WETH();
        path[1] = _diaToken;
        uint256 bal = getEtherBalance(); // balance after payment
        IUniswap(_uniswap).swapExactETHForTokens{value : msg.value}( // all msg.value may/maynot be used
            paymentInDia_, // min dia tokens we want
            path,
            msg.sender, // dia token receiver
            deadline
        );
        bal -= getEtherBalance();
        // refund leftover ETH to user
        payable(msg.sender).transfer(msg.value - bal);
    }
    
    function addLiquidityByEther_Dia(
        uint diaAmount_,
        uint minDiaAmount_,
        uint minEtherAmount_,
        address lptReceiver_,
        uint deadline_  // ms
        ) public payable {
        // this contract must approve uniswap Router Contract
        // to spent our dia tokens
        deadline_ += block.timestamp;
        IERC20(_diaToken).approve(_uniswap, diaAmount_);
        IUniswap(_uniswap).addLiquidityETH{value: msg.value}(_diaToken, diaAmount_, minDiaAmount_, minEtherAmount_, lptReceiver_, deadline_);
    }
    
    function getDiaBalanceOf(address of_) public view returns (uint256) {
        return IERC20(_diaToken).balanceOf(of_);
    }
    
    function getDiaBalance() public view returns (uint) {
        return IERC20(_diaToken).balanceOf(address(this));
    }
    
    function getEtherBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function withdrawAllEther(address to_) public onlyOwner {
        if(to_ == address(0)) to_ = _owner;
        _withdraw(to_, getEtherBalance());
    }
    
    function withdrawEther(address to_, uint256 amount_) public onlyOwner {
        uint256 b = getEtherBalance();
        require(amount_ <= b, "Insufficient Funds!");
        if(to_ == address(0)) to_ = _owner;
        _withdraw(to_, amount_);
    }
    
    function _withdraw(address to_, uint256 amount_) internal {
        payable(to_).transfer(amount_);
    }
    
    function withdrawAllDia(address to_) public onlyOwner {
        if(to_ == address(0)) to_ = _owner;
        _withdrawDia(to_, getDiaBalance());
    }
    
    function withdrawDia(address to_, uint256 amount_) public onlyOwner {
        uint256 b = getDiaBalance();
        require(amount_ <= b, "Insufficient Funds!");
        if(to_ == address(0)) to_ = _owner;
        _withdrawDia(to_, amount_);
    }
    
    function _withdrawDia(address to_, uint256 amount_) internal {
        IERC20(_diaToken).transfer(to_, amount_);
    }
    
    modifier onlyOwner {
        require(msg.sender == _owner ,"MyDefiV2:: Forbidden!");
        _;
    }
    
    // to receive the extra funds while adding liquidity
    receive() external payable {}
}