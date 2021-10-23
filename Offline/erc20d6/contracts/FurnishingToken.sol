pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IFIST {
    function safeTransferFrom(address from, address to, uint256 tokenid) external;
} 

// FTC --> Furnishing Token Contract, FSC --> FIST Selling Contract
contract FISTSellingContract is IERC721Receiver {
    address private _ftcAddress;
    address private _fscOwnerAddress;
    address private _ftcOwnerAddress;
    uint256 private _pricePerFIST;
    
    uint256 _totalTokens;
    uint256[] _tokensOwned;
    uint _tokensSoldSoFar;
    uint _myProfitPercent = 10; // 10 percent
    
    
    
    event FISTReceived(address, address, uint256);
    event FISTSold(address, uint256);
    event WithDrawn(address, uint);
    
    constructor(address ftcAddress_, address ftcOwnerAddress_){
        _fscOwnerAddress = msg.sender;
        _ftcAddress = ftcAddress_;
        _ftcOwnerAddress = ftcOwnerAddress_;
    }
    
    function setPrice(uint256 price_) public onlyfcOwner {
        require(price_ > 0);
        _pricePerFIST = price_;
    }
    
    function getPrice() public view returns (uint256) {
        return _pricePerFIST;
    }
    
    function getStock() public view returns (uint256){
        return _tokensOwned.length;
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    
    function buyFIST() public payable {
        require(msg.value == _pricePerFIST, "Amount must be equal to the token price");
        require(_tokensOwned.length > 0);
        // require(msg.value % _pricePerFIST == 0, "Amount must be multiple of Price");
        // uint16 numOfTokens = msg.value / _pricePerFIST;
        ++_tokensSoldSoFar;
        uint256 tokenId = _tokensOwned[--_totalTokens];
        delete _tokensOwned[_totalTokens];
        IFIST(_ftcAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        
        emit FISTSold(msg.sender, tokenId);
    }
    
    function withDraw() public onlyfcOwnerORfscOwner {
        uint amnt = address(this).balance;
        if(msg.sender == _ftcOwnerAddress){
            require(_tokensSoldSoFar > 0);
            _tokensSoldSoFar = 0;
            amnt = amnt - amnt/_myProfitPercent;
        }
        require(amnt > 0, "Insufficient balance.");
        payable(msg.sender).transfer(amnt);
        emit WithDrawn(msg.sender, amnt);
    }
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4){
        _tokensOwned.push(tokenId);
        ++_totalTokens;
        emit FISTReceived(operator, from, tokenId);    
    }
    
    modifier onlyfcOwner {
        require(msg.sender == _ftcOwnerAddress);
        _;
    }
    
    modifier onlyfscOwner {
        require(msg.sender == _fscOwnerAddress);
        _;
    }
    
    modifier onlyfcOwnerORfscOwner {
        require(msg.sender == _ftcOwnerAddress || 
                    msg.sender == _fscOwnerAddress);
        _;
    }
}