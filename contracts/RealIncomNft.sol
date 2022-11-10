// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


import "@hardhat/console.sol";

pragma solidity ^0.8.7;

contract RealIncomNft is ERC721, ERC721URIStorage, Counters{
    uint256 tokenIdCounter;
    string private NftBaseURI;
    
    event NftMinted(uint256 tokenId, string metadataURI, string title, string description, address owner);

    struct DigiAsset {
        string title;
        string description;
        address creator;
    }
    mapping(uint256 => DigiAsset) public tokenIdToNft;
    constructor() ERC721("Real Income", "INCOM"){
        tokenIdCounter = 0;
    }

    function mintNFT(address _owner, string _title, string _description, string _digiURI)  returns (uint256) {
        tokenIdCounter += 1;
        tokenIdToNft[tokenIdCounter] = DigiAsset(_title, _description, msg.sender);
        _safeMint(to, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _digiURI);
        emit NftMinted(tokenIdCounter, _digiURI, _title, _description, msg.sender);
    }


    function setBaseURI(string memory _baseUri) public {
        NftBaseURI = _baseUri;
    }

    function _baseURI() public view returns(string memeory){
        return NftBaseURI;
    }
}