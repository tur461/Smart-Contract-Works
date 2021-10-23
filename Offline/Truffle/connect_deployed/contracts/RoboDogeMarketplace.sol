import "../node_modules/openzeppelin-solidity/contracts/security/ReentrancyGuard.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";

interface RoboDogeCoin {
    // erc20
    function balanceOf(address _address) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

interface RoboDogeNft {
    // erc721
    function mint(
        address _owner,
        string memory _metadata,
        uint256 _count
    ) external;

    function ownerOf(uint256 _tokenId) external view returns (address);

    function exists(uint256 _tokenId) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function enableTokenTransfer(uint256 _tokenId) external;

    function disableTokenTransfer(uint256 _tokenId) external;

    function isTransferDisabled(uint256 _tokenId) external view returns (bool);
}

contract RoboDogeMarketplace is Ownable, ReentrancyGuard {
    enum Currency {
        TOKEN,
        BNB
    }
    struct Sale {
        uint256 price;
        Currency currency;
    }
    struct Auction {
        uint256 startingBid;
        uint256 startingTime;
        uint256 duration;
        address highestBidder;
        uint256 highestBid;
        Currency currency;
    }

    RoboDogeCoin private token;
    RoboDogeNft private nft;

    uint256 private constant DENOMINATOR = 10000;
    uint256 private constant MAX_AUCTION_DURATION = 14;
    uint256 private constant MIN_BID_RISE = 500;
    uint256 public royalty; // percentage original owner of nft will be getting
    uint256 public mintFee;
    uint256 public minTokenBalance;

    mapping(string => bool) public exists;
    mapping(uint256 => Sale) public nftSales;
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) public tokenBidders;

    event NFTPutOnSale(uint256 indexed tokenId, uint256 indexed price);
    event NFTRemovedFromSale(uint256 indexed tokenId);
    event NFTSold(uint256 indexed tokenId, uint256 indexed price);
    event AuctionStart(
        uint256 indexed tokenId,
        uint256 indexed startingBid,
        uint256 indexed startingTime
    );
    event AuctionCancel(uint256 indexed tokenId);
    event PlaceBid(uint256 indexed tokenId, uint256 indexed bid);

    modifier isOwner(uint256 _tokenId) {
        require(
            msg.sender == nft.ownerOf(_tokenId),
            "Only owner can remove NFT from sale"
        );
        _;
    }
    modifier nftExists(uint256 _tokenId) {
        require(nft.exists(_tokenId), "NFT does not exist");
        _;
    }
    modifier isOnSale(uint256 _tokenId) {
        require(
            nftSales[_tokenId].price > 0 &&
                nft.ownerOf(_tokenId) == address(this) &&
                nft.isTransferDisabled(_tokenId),
            "NFT is not on sale"
        );
        _;
    }
    modifier notOnSale(uint256 _tokenId) {
        require(
            nftSales[_tokenId].price == 0 && !nft.isTransferDisabled(_tokenId),
            "NFT is on sale"
        );
        _;
    }
    modifier isOnAuction(uint256 _tokenId) {
        require(auctions[_tokenId].startingTime > 0, "NFT not being auctioned");
        _;
    }
    modifier notOnAuction(uint256 _tokenId) {
        require(
            auctions[_tokenId].startingTime == 0,
            "NFT already being auctioned"
        );
        _;
    }

    constructor(
        address _nft,
        address _token,
        uint256 _mintFee,
        uint256 _minTokenBalance,
        uint256 _royalty
    ) {
        token = RoboDogeCoin(_token);
        nft = RoboDogeNft(_nft);
        mintFee = _mintFee;
        minTokenBalance = _minTokenBalance;
        royalty = _royalty;
    }

    /*
        imagehash not exist
        payment > mintfee per nft times count of nft to mint
        tken balance of sender is >= min token balance allowed for a minter
    */
    function mint(
        string memory _imageHash,
        string memory _metadata,
        uint256 _count
    ) external payable nonReentrant {
        require(!exists[_imageHash], "Image already exists");
        require(msg.value >= mintFee * _count, "Insufficient funds received");
        require(
            token.balanceOf(msg.sender) >= minTokenBalance,
            "Not enough RoboDoge tokens"
        );
        exists[_imageHash] = true;
        nft.mint(msg.sender, _metadata, _count);
    }

    // approve first
    function putOnSale(
        uint256 _tokenId,
        uint256 _price,
        Currency _currency
    )
        external
        nftExists(_tokenId)
        isOwner(_tokenId)
        notOnSale(_tokenId)
        notOnAuction(_tokenId)
    {
        require(_price > 0, "Price cannot be zero");
        nftSales[_tokenId] = Sale(_price, _currency);
        nft.disableTokenTransfer(_tokenId);
        emit NFTPutOnSale(_tokenId, _price);
    }

    function removeFromSale(uint256 _tokenId)
        external
        nftExists(_tokenId)
        isOwner(_tokenId)
        isOnSale(_tokenId)
    {
        delete nftSales[_tokenId];
        nft.enableTokenTransfer(_tokenId);
        emit NFTRemovedFromSale(_tokenId);
    }

    // approve first
    function buyNft(uint256 _tokenId)
        external
        payable
        nonReentrant
        nftExists(_tokenId)
        isOnSale(_tokenId)
    {
        require(
            nftSales[_tokenId].currency == Currency.BNB &&
                msg.value >= nftSales[_tokenId].price,
            "Insufficient funds sent"
        );
        require(
            token.balanceOf(msg.sender) >= minTokenBalance,
            "Not enough RoboDoge tokens"
        );
        address originalOwner = nft.ownerOf(_tokenId);
        uint256 price = nftSales[_tokenId].price;
        uint256 royaltyFee = (price * royalty) / DENOMINATOR;
        Currency currency = nftSales[_tokenId].currency;
        delete nftSales[_tokenId];
        if (currency == Currency.BNB) {
            payable(originalOwner).transfer(price - royaltyFee);
            payable(msg.sender).transfer(msg.value - price);
        } else {
            token.transferFrom(msg.sender, originalOwner, price - royaltyFee);
        }
        nft.enableTokenTransfer(_tokenId);
        nft.safeTransferFrom(originalOwner, msg.sender, _tokenId);
        emit NFTSold(_tokenId, price);
    }

    // approve first
    function startAuction(
        uint256 _tokenId,
        uint256 _startingBid,
        uint256 _duration,
        Currency _currency
    )
        external
        nftExists(_tokenId)
        isOwner(_tokenId)
        notOnSale(_tokenId)
        notOnAuction(_tokenId)
    {
        require(_duration <= MAX_AUCTION_DURATION, "Decrease auction duration");
        auctions[_tokenId] = Auction(
            _startingBid,
            block.timestamp,
            _duration,
            address(0),
            0,
            _currency
        );
        nft.disableTokenTransfer(_tokenId);
        emit AuctionStart(_tokenId, _startingBid, block.timestamp);
    }

    function deleteAuction(uint256 _tokenId)
        external
        nftExists(_tokenId)
        isOwner(_tokenId)
        isOnAuction(_tokenId)
    {
        require(
            auctions[_tokenId].highestBid == 0,
            "Cannot delete once bid is placed"
        );
        delete auctions[_tokenId];
        nft.enableTokenTransfer(_tokenId);
        emit AuctionCancel(_tokenId);
    }

    function placeBid(uint256 _tokenId, uint256 _bid)
        external
        payable
        nonReentrant
        nftExists(_tokenId)
        isOnAuction(_tokenId)
    {
        Auction storage item = auctions[_tokenId];
        uint256 bid = item.currency == Currency.BNB ? msg.value : _bid;
        uint256 auctionEndTime = auctions[_tokenId].startingTime +
            auctions[_tokenId].duration *
            1 days;
        uint256 nextAllowedBid = item.highestBid == 0
            ? item.startingBid
            : item.highestBid + (item.highestBid * MIN_BID_RISE) / DENOMINATOR;
        require(bid >= nextAllowedBid, "Increase bid");
        require(block.timestamp <= auctionEndTime, "Auction duration ended");
        uint256 prevBid = item.highestBid;
        address prevBidder = item.highestBidder;
        delete tokenBidders[_tokenId][prevBidder];
        item.highestBid = bid;
        item.highestBidder = msg.sender;
        tokenBidders[_tokenId][msg.sender] = bid;
        if (item.currency == Currency.BNB) {
            payable(prevBidder).transfer(prevBid);
        } else {
            token.transfer(prevBidder, prevBid); // check for eop limit
            token.transferFrom(msg.sender, address(this), bid);
        }
        emit PlaceBid(_tokenId, bid);
    }

    function claimAuctionNft(uint256 _tokenId)
        external
        nonReentrant
        nftExists(_tokenId)
        isOnAuction(_tokenId)
    {
        Auction memory item = auctions[_tokenId];
        require(
            (msg.sender == item.highestBidder &&
                block.timestamp > item.startingTime + item.duration * 1 days) ||
                msg.sender == nft.ownerOf(_tokenId),
            "Only highest bidder or owner can call"
        );
        Currency currency = item.currency;
        uint256 highestBid = item.highestBid;
        address highestBidder = item.highestBidder;
        uint256 royaltyFee = (highestBid * royalty) / DENOMINATOR;
        delete auctions[_tokenId];
        delete tokenBidders[_tokenId][highestBidder];
        if (currency == Currency.BNB) {
            payable(nft.ownerOf(_tokenId)).transfer(highestBid - royaltyFee);
        } else {
            token.transfer(nft.ownerOf(_tokenId), highestBid - royaltyFee);
        }
        nft.enableTokenTransfer(_tokenId);
        nft.safeTransferFrom(nft.ownerOf(_tokenId), highestBidder, _tokenId);
    }

    // ------------ VIEW FUNCTIONS ------------
    function getAuctionInfo(uint256 _tokenId)
        external
        view
        nftExists(_tokenId)
        returns (bool, Auction memory)
    {
        return (
            auctions[_tokenId].highestBid == 0 ? false : true,
            auctions[_tokenId]
        );
    }

    function canClaimAuctionNft(address _address, uint256 _tokenId)
        external
        view
        nftExists(_tokenId)
        isOnAuction(_tokenId)
        returns (bool)
    {
        Auction memory item = auctions[_tokenId];
        return (item.highestBid > 0 &&
            block.timestamp > item.startingTime + item.duration * 1 days &&
            _address == item.highestBidder);
    }

    //  ------------ ONLY OWNER FUNCTIONS ------------
    function updateMintFee(uint256 _mintFee) external onlyOwner {
        mintFee = _mintFee;
    }

    function updateRoyaltyFee(uint256 _royaltyFee) external onlyOwner {
        royalty = _royaltyFee;
    }

    function updateMinimumTokenBalance(uint256 _minTokenBalance)
        external
        onlyOwner
    {
        minTokenBalance = _minTokenBalance;
    }

    function withdrawRoyalty(address payable _address) external onlyOwner {
        require(_address != address(0), "Address cannot be zero address");
        _address.transfer(address(this).balance);
        token.transfer(_address, token.balanceOf(address(this)));
    }

    receive() external payable {}
}
