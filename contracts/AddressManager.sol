// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./RealIncomAccessControl.sol";
import "./RealIncomNft.sol";
import "./RealIncomAuction.sol";
import "./VillageSquare.sol";
import "./RealIncomLoan.sol";

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

    RealIncomAccessControl private _accessController;
    RealIncomNft private _nftContract;
    RealIncomAuction private _auctionContract;
    VillageSquare private _villageSquareContract;
    RealIncomLoan private _loanContract;

    constructor(
        RealIncomAccessControl _accessControlAddress,
        RealIncomAuction _auctionAddress,
        RealIncomNft _nftAddress,
        VillageSquare _villageSquareAddress,
        RealIncomLoan _loanAddress
    ) {
        accessControlAddress = address(_accessControlAddress);
        auctionAddress = address(_auctionAddress);
        nftAddress = address(_nftAddress);
        addressManagerAddress = address(this);
        loanAddress = address(_loanAddress);
        villageSquareAddress = address(_villageSquareAddress);
        _accessController = RealIncomAccessControl(_accessControlAddress);
        _nftContract = RealIncomNft(_nftAddress);
        _auctionContract = RealIncomAuction(_auctionAddress);
        _villageSquareContract = VillageSquare(_villageSquareAddress);
        _loanContract = RealIncomLoan(_loanAddress);
    }

    modifier onlyAuthorized() {
        require(
            _accessController.isAuthorized(msg.sender),
            "Only authorized handlers are allowed!"
        );
        _;
    }

    function updateAccessControlAddress(
        RealIncomAccessControl _accessControlAddress
    ) public onlyAuthorized {
        accessControlAddress = address(_accessControlAddress);
        _accessController = RealIncomAccessControl(_accessControlAddress);
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
        RealIncomAuction _auctionAddress
    ) public onlyAuthorized {
        auctionAddress = address(_auctionAddress);
        _auctionContract = RealIncomAuction(_auctionAddress);
        _villageSquareContract.updateAuctionContract(_auctionAddress);
        emit AuctionAddressUpdated(address(_auctionAddress), msg.sender);
    }

    function updateNftAddress(address _nftAddress) public onlyAuthorized {
        nftAddress = _nftAddress;
        _nftContract = RealIncomNft(_nftAddress);
        emit NftAddressUpdated(_nftAddress, msg.sender);
    }

    function updateVillageSquareAddress(
        address _villageSquareAddress
    ) public onlyAuthorized {
        villageSquareAddress = _villageSquareAddress;
        _villageSquareContract = VillageSquare(_villageSquareAddress);
        emit VillageSquareUpdated(_villageSquareAddress, msg.sender);
    }

    function updateLoanAddress(RealIncomLoan _loanAddress) public onlyAuthorized {
        loanAddress = address(_loanAddress);
        _loanContract = RealIncomLoan(_loanAddress);
        emit LoanUpdated(address(_loanAddress), msg.sender);
    }
}
