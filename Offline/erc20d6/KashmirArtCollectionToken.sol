pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

contract KashmirArtCollectionToken is ERC721 {
	constructor(string memory n_, string memory s_) ERC721(n_, s_) {}
}