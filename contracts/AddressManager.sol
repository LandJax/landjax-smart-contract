// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./LandjaxAccessControl.sol";
import "./LandjaxNft.sol";
import "./LandjaxAuction.sol";
import "./VillageSquare.sol";
import "./LandjaxLoan.sol";

contract AddressManager {
    address public accessControlAddress;
    address public auctionAddress;
    address public nftAddress;
    address public villageSquareAddress;
    address public addressManagerAddress;
    address public loanAddress;

    event AccessControlAddressUpdated(
        address AccessControlAddress,
        address innitiator
    );
    event AuctionAddressUpdated(address AuctionAddress, address innitiator);
    event NftAddressUpdated(address NftAddress, address innitiator);
    event VillageSquareUpdated(
        address VillageSquareAddress,
        address innitiator
    );
    event LoanUpdated(address loanAddress, address innitiator);

    landjaxAccessControl private _accessController;
    landjaxNft private _nftContract;
    landjaxAuction private _auctionContract;
    VillageSquare private _villageSquareContract;
    landjaxLoan private _loanContract;

    constructor(
        landjaxAccessControl _accessControlAddress,
        landjaxAuction _auctionAddress,
        landjaxNft _nftAddress,
        VillageSquare _villageSquareAddress,
        landjaxLoan _loanAddress
    ) {
        accessControlAddress = address(_accessControlAddress);
        auctionAddress = address(_auctionAddress);
        nftAddress = address(_nftAddress);
        addressManagerAddress = address(this);
        loanAddress = address(_loanAddress);
        villageSquareAddress = address(_villageSquareAddress);
        _accessController = landjaxAccessControl(_accessControlAddress);
        _nftContract = landjaxNft(_nftAddress);
        _auctionContract = landjaxAuction(_auctionAddress);
        _villageSquareContract = VillageSquare(_villageSquareAddress);
        _loanContract = landjaxLoan(_loanAddress);
    }

    modifier onlyAuthorized() {
        require(
            _accessController.isAuthorized(msg.sender),
            "Only authorized handlers are allowed!"
        );
        _;
    }

    function updateAccessControlAddress(
        landjaxAccessControl _accessControlAddress
    ) public onlyAuthorized {
        accessControlAddress = address(_accessControlAddress);
        _accessController = landjaxAccessControl(_accessControlAddress);
        _nftContract.updateAccessControlContract(_accessControlAddress);
        _villageSquareContract.updateAccessControlContract(
            _accessControlAddress
        );
        _auctionContract.updateAccessControlContract(_accessControlAddress);
        emit AccessControlAddressUpdated(
            address(_accessControlAddress),
            msg.sender
        );
    }

    function updateAuctionAddress(
        landjaxAuction _auctionAddress
    ) public onlyAuthorized {
        auctionAddress = address(_auctionAddress);
        _auctionContract = landjaxAuction(_auctionAddress);
        _villageSquareContract.updateAuctionContract(_auctionAddress);
        emit AuctionAddressUpdated(address(_auctionAddress), msg.sender);
    }

    function updateNftAddress(address _nftAddress) public onlyAuthorized {
        nftAddress = _nftAddress;
        _nftContract = landjaxNft(_nftAddress);
        emit NftAddressUpdated(_nftAddress, msg.sender);
    }

    function updateVillageSquareAddress(
        address _villageSquareAddress
    ) public onlyAuthorized {
        villageSquareAddress = _villageSquareAddress;
        _villageSquareContract = VillageSquare(_villageSquareAddress);
        emit VillageSquareUpdated(_villageSquareAddress, msg.sender);
    }

    function updateLoanAddress(landjaxLoan _loanAddress) public onlyAuthorized {
        loanAddress = address(_loanAddress);
        _loanContract = landjaxLoan(_loanAddress);
        emit LoanUpdated(address(_loanAddress), msg.sender);
    }
}
