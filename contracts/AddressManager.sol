// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./RealIncomAccessControl.sol";
import "./RealIncomNft.sol";
import "./RealIncomAuction.sol";
import "./VillageSquare.sol";


contract AddressManager{

    

    address public accessControlAddress;
    address public auctionAddress;
    address public nftAddress;
    address public villageSquareAddress;
    address public addressManagerAddress;

    event AccessControlAddressUpdated(address AccessControlAddress, address innitiator);
    event AuctionAddressUpdated(address AuctionAddress, address innitiator);
    event NftAddressUpdated(address NftAddress, address innitiator);
    event VillageSquareUpdated(address VillageSquareAddress, address innitiator);


    RealIncomAccessControl private _accessController;
    RealIncomNft     private      _nftContract;
    RealIncomAuction   private    _auctionContract;
    VillageSquare    private      _villageSquareContract;

    constructor(address _accessControlAddress, address _auctionAddress, address _nftAddress, address _villageSquareAddress){
        accessControlAddress = _accessControlAddress;
        auctionAddress = _auctionAddress;
        nftAddress = _nftAddress;
        addressManagerAddress = address(this);
        villageSquareAddress = _villageSquareAddress;
        _accessController = RealIncomAccessControl(_accessControlAddress);
        _nftContract = RealIncomNft(_nftAddress);
        _auctionContract = RealIncomAuction(_auctionAddress);
        _villageSquareContract = VillageSquare(_villageSquareAddress);
       
    }

    modifier onlyAuthorized {
        require(_accessController.isAuthorized(msg.sender), "Only authorized handlers are allowed!");
    }

    function updateAccessControlAddress(address _accessControlAddress) public onlyAuthorized{
        accessControlAddress = _accessControlAddress;
        _accessController = RealIncomAccessControl(_accessControlAddress);
        _nftContract.updateAccessControlContract(_accessControlAddress);
        _villageSquareContract.updateAccessControlContract(_accessControlAddress);
        _auctionContract.updateAccessControlContract(_accessControlAddress);
        emit AccessControlAddressUpdated(_accessControlAddress, msg.sender);
    }

    function updateAuctionAddress(address _auctionAddress) public onlyAuthorized{
        auctionAddress = _auctionAddress;
        _auctionContract = RealIncomAuction(_auctionAddress);
        _villageSquareContract.updateAuctionContract(_auctionAddress);
        emit AuctionAddressUpdated(_auctionAddress, msg.sender);
    }

    function updateNftAddress(address _nftAddress) public onlyAuthorized{
        nftAddress = _nftAddress;
        _nftContract.updateNftContract(_nftAddress);
        _nftContract = RealIncomNft(_nftAddress);
        emit NftAddressUpdated(_nftAddress, msg.sender);
    }

    function updateVillageSquareAddress(address _villageSquareAddress) public onlyAuthorized{
        villageSquareAddress = _villageSquareAddress;
        _villageSquareContract = VillageSquare(_villageSquareAddress);
        emit VillageSquareUpdated(_villageSquareAddress, msg.sender);
    }
}