pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Counters.sol";
import "./Strings.sol";

contract RoboDodgeNFT is ERC721 {
    using Counters for Counters.Counter;
    
    struct TokenData {
        string imageHash;
        string metadata;
        bool transferEnabled;
        bool exists;
    }
    
    Counters.Counter private _tokenIds;
    address public _owner;
    
    mapping(uint256 => TokenData) tokenData;
    
    event WithDrawn(address, uint);
    
    constructor() public ERC721("RoboDoge NFT", "RDN") {
        _owner = msg.sender;
    }
    
    function deposit() public payable {}
    
    function withDraw() public onlyOwner {
        uint bal = address(this).balance;
        payable(msg.sender).transfer(bal);
        emit WithDrawn(msg.sender, bal);
    }

    function mint(
        address to_, 
        string memory hash_, 
        string memory meta_
    ) external onlyOwner returns (uint256 newTokenId) {
        _tokenIds.increment();
        newTokenId = _tokenIds.current();
        _safeMint(to_, newTokenId);
        tokenData[newTokenId] = TokenData(hash_, meta_, false, true);
        return newTokenId;
    }
    function burn(uint256 tokenid_) external {
        _burn(tokenid_);
    }
    
    function disableTokenTransfer(uint256 tokenid_) external tokenOwnerOrApproved(tokenid_) {
        tokenData[tokenid_].transferEnabled = false;
    }
    
    function enableTokenTransfer(uint256 tokenid_) external tokenOwnerOrApproved(tokenid_) {
        tokenData[tokenid_].transferEnabled = true;
    }
    
    function isTransferEnabled(uint256 tokenid_) external view returns(bool) {
        return tokenData[tokenid_].transferEnabled;
    }
    
    function isTransferDisabled(uint256 tokenid_) external view returns(bool) {
        return !tokenData[tokenid_].transferEnabled;
    }
    
    function exists(uint256 tokenid_) external view returns(bool) {
        return _exists(tokenid_);
    }
    
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }
    
    modifier tokenOwner(uint256 tokenid_) {
        require(msg.sender == ownerOf(tokenid_), "you are not the token owner");
        _;
    }
    
    
    modifier tokenOwnerOrApproved(uint256 tokenid_) {
        require(msg.sender == ownerOf(tokenid_) || 
                msg.sender == getApproved(tokenid_), "You are not allowed to do that.");
        _;
    }
}