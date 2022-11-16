// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./RealIncomAccessControl.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RealIncomNft is ERC721URIStorage {
    uint256 tokenIdCounter;
    string private NftBaseURI;
    RealIncomAccessControl accessController;

    event NftMinted(
        address owner,
        string title,
        string description,
        string digiURI,
        int256 amount,
        uint256 tokenId
    );

    event  AccessControlContractUpdated(address indexed accessController, address indexed innitiator);
    struct DigiAsset {
        address _owner;
        string _title;
        string _description;
        string _digiURI;
        uint256 netWorth;
        uint256 _tokenId;
    }
    mapping(uint256 => DigiAsset) public tokenIdToNft;

    constructor(address _accessController) ERC721("Real Income", "INCOM") {
        tokenIdCounter = 0;
        accessController = RealIncomAccessControl(_accessController);
    }

    function mintNFT(
        string memory _title,
        string memory _description,
        string memory _digiURI
        
    ) public returns (uint256) {
        tokenIdCounter += 1;
        tokenIdToNft[tokenIdCounter] = DigiAsset(
            msg.sender,
            _title,
            _description,
            _digiURI,
            0,
            tokenIdCounter
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
        _;
    }

    function setBaseURI(string memory _baseUri) public onlyAuthorized {
        NftBaseURI = _baseUri;
    }

    function baseURI() public view returns (string memory) {
        return NftBaseURI;
    }

    function setNftValue(uint256 nftWorth, uint256 _tokenId) public {
        tokenIdToNft[_tokenId].netWorth = nftWorth;
    }

    function safeTransfer( address from,
        address to,
        uint256 tokenId) public {
         require(isApprovedForAll(msg.sender, address(this)), "ERC721: caller is not token owner or approved");
         tokenIdToNft[tokenId]._owner = msg.sender;
        _safeTransfer(from, to, tokenId, "");
    }

    function updateAccessControlContract(address _accessController) public onlyAuthorized{
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(_accessController, msg.sender);

    }
}
