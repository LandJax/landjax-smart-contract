// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./RealIncomAccessControl.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RealIncomNft is ERC721URIStorage, ReentrancyGuard {
    uint256 tokenIdCounter;
    string private NftBaseURI;
    RealIncomAccessControl accessController;

    event NftMinted(
        address owner,
        string title,
        string description,
        string digiURI,
        int256 amount,
        uint256 tokenId,
        string productLink
    );

    event  AccessControlContractUpdated(address indexed accessController, address indexed innitiator);
    struct DigiAsset {
        address _owner;
        string _title;
        string _description;
        string _digiURI;
        uint256 _worth;
        uint256 _tokenId;
        uint256 _productAge;
        string _revenue;
        string _expenses;
        string _traffic;
        string location;
        string _productLink;
    }
    mapping(uint256 => DigiAsset) public tokenIdToNft;

    constructor(address _accessController) ERC721("Real Income", "INCOM") {
        tokenIdCounter = 0;
        accessController = RealIncomAccessControl(_accessController);
    }

    function mintNFT(
        string memory _title,
        string memory _description,
        string memory _digiURI,
        uint256 productAge
        
    ) public returns (uint256) {
        tokenIdCounter += 1;
        tokenIdToNft[tokenIdCounter] = DigiAsset(
            msg.sender,
            _title,
            _description,
            _digiURI,
            0,
            tokenIdCounter,
            productAge
        );
        _safeMint(msg.sender, tokenIdCounter);
        _setTokenURI(tokenIdCounter, _digiURI);
        emit NftMinted(
            msg.sender,
            _title,
            _description,
            _digiURI,
            0,
            tokenIdCounter
        );
        return tokenIdCounter;
    }

    modifier onlyAuthorized() {
        require(
            accessController.isAuthorized(msg.sender),
            "You're not Authorized"
        );

        // if (!accessController.isAuthorized(msg.sender)){
        //     revert("You're not Authorized");
        // }
        _;
    }

    function setBaseURI(string memory _baseUri) public onlyAuthorized {
        NftBaseURI = _baseUri;
    }

    function baseURI() public view returns (string memory) {
        return NftBaseURI;
    }

    function setNftValue(uint256 nftWorth, uint256 _tokenId) public {
        tokenIdToNft[_tokenId].worth = nftWorth;
    }

    function safeTransfer( address from,
        address to,
        uint256 tokenId) public nonReentrant{
         require(isApprovedForAll(msg.sender, address(this)), "ERC721: caller is not token owner or approved");
         tokenIdToNft[tokenId]._owner = msg.sender;
        _safeTransfer(from, to, tokenId, "");
    }

    function updateAccessControlContract(address _accessController) public onlyAuthorized{
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(_accessController, msg.sender);

    }

    
}
