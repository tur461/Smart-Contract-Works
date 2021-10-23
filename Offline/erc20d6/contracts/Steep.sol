pragma solidity ^0.8.0;

import "./IERC20.sol";

contract SteepServicePayableToken is IERC20 {
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    
    constructor (string memory name_, string memory sym_, uint8 dec_, uint256 sup_){
        _name = name_;
        _symbol = sym_;
        _decimals = dec_;
        _totalSupply = sup_;
        _owner = msg.sender;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account_) public view returns (uint256) {
        return _balances[account_];
    }
    
    function transfer(address recipient_, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient_, amount);
        return true;
    }
    
    function transferFrom(
        address sender_,
        address recipient_,
        uint256 amount_
    ) public returns (bool) {
        _transfer(sender_, recipient_, amount_);

        uint256 currentAllowance = _allowances[sender_][msg.sender];
        require(currentAllowance >= amount_, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender_, msg.sender, currentAllowance - amount_);
        }

        return true;
    }
    
    function allowance(address owner_, address spender_) public view returns (uint256) {
        return _allowances[owner_][spender_];
    }
    
    function increaseAllowance(address spender_, uint256 addedValue_) public returns (bool) {
        _approve(msg.sender, spender_, _allowances[msg.sender][spender_] + addedValue_);
        return true;
    }
    
    function decreaseAllowance(address spender_, uint256 subtractedValue_) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender_];
        require(currentAllowance >= subtractedValue_, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender_, currentAllowance - subtractedValue_);
        }

        return true;
    }
    
    function approve(address spender_, uint256 amount_) public returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }
    
    function mint(uint256 amount_) public onlyOwner {
        _mint(msg.sender, amount_);
    }
    
    function burn(uint256 amount_) public {
        _burn(msg.sender, amount_);
    }
    
    function burnIndirect(address address_, uint256 amount_) public {
        require(address_ != address(0));
        _burn(address_, amount_);
    }
    
    function deposit(uint256 ethAmount_) public payable {
        require(msg.value == ethAmount_);
        require(ethAmount_ > 0);
    }
    
    function withDraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function _transfer(
        address sender_,
        address recipient_,
        uint256 amount_
    ) internal virtual {
        require(sender_ != address(0), "ERC20: transfer from the zero address");
        require(recipient_ != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender_];
        require(senderBalance >= amount_, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender_] = senderBalance - amount_;
        }
        _balances[recipient_] += amount_;

        emit Transfer(sender_, recipient_, amount_);
    }
    
    function _mint(address account_, uint256 amount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount_;
        _balances[account_] += amount_;
        emit Transfer(address(0), account_, amount_);
    }
    
    function _burn(address account_, uint256 amount_) internal virtual {
        require(account_ != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account_];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account_] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account_, address(0), amount);
    }
    
    function _approve(
        address owner_,
        address spender_,
        uint256 amount_
    ) internal virtual {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender_ != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }
    
    
    
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }
}