// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./RealIncomNft.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RealIncomAccessControl.sol";

contract RealIncomAuction is Ownable {
    using SafeMath for uint256;

    RealIncomAccessControl accessController;

    RealIncomNft nftContract;
    uint256 minimumBidIncrement = 1e18;
    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 reservedPrice;
        uint256 endTime;
        address seller;
        bool onSale;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 auctionIdCounter;

    mapping(address => uint256) public bids;

    struct HighestBidder {
        address bidder;
        uint256 bid;
        uint256 bidTime;
    }

    // Token Id to higestBidder
    mapping(uint256 => HighestBidder) public highestBids;

    event AuctionCreated(
        uint256 tokenId,
        uint256 startTime,
        uint256 reservedPrice,
        uint256 endTime,
        address seller
    );

    event BidPlaced(uint256 BidAmount, uint256 Bidder, uint256 bidTime);

    event AuctionCancelled(uint256 auctionId, uint256 tokenId, address seller);

    event AuctionStartTimeModified(
        uint256 auctionId,
        uint256 tokenId,
        address seller,
        uint256 startTime
    );

    event AuctionResulted(
        address seller,
        address winner,
        uint256 winningBid,
        uint256 endTime
    );

    event AuctionEndTimeModified(
        uint256 auctionId,
        uint256 tokenId,
        address seller,
        uint256 endTime
    );

    event AuctionBalanceWithdrawn(address to, address from, uint256 amount);

    modifier onlyAuthorized() {
        require(
            accessController.isAuthorized(msg.sender),
            "You're not Authorized"
        );
        _;
    }

    constructor(address IncomNft, address _accessController) {
        nftContract = RealIncomNft(IncomNft);
        accessController = RealIncomAccessControl(_accessController);
        auctionId = 0;
    }

    // Start Auction
    function startAuction(
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime,
        uint256 reservedPrice
    ) public {
        auctionIdCounter += 1;
        auctions[auctionIdCounter] = Auction(
            tokenId,
            startTime,
            reservedPrice,
            endTime,
            msg.sender,
            true
        );
        emit AuctionCreated(
            tokenId,
            startTime,
            reservedPrice,
            endTime,
            msg.sender
        );
        return auctionIdCounter;
    }

    // cancel Auction
    function cancelAuction(uint256 _auctionId) public {
        require(
            msg.sender == auctions[auctionId].seller,
            "You are not the seller"
        );
        auctions[_auctionId].onSale = false;
        emit AuctionCancelled(
            _auctionId,
            auctions[auctionId].tokenId,
            msg.sender
        );
    }

    // Place Bid

    function placeBid(uint256 auctionId) public payable {
        require(
            block.timestamp < auctions[autionId].endTime,
            "Auction has ended"
        );
        require(msg.sender != address(0), "this is the address 0x00.. address");
        HighestBidder highestBidder = highestBids[auctions[auctionId].tokenId];
        uint256 minBid = highestBidder.bid.add(minimumBidIncrement);
        if (highestBidder.bid == 0) {
            minBid = highestBids[auctions[auctionId].tokenId].reservedPrice.add(
                    minimumBidIncrement
                );
        }

        require(msg.value > minBid, "You did not outbid the highest bidder");
        payable(highestBidder.bidder).transfer(highestBidder.bid);
        delete highestBids[auctions[auctionId].tokenId];
        highestBids[auctions[auctionId].tokenId] = HighestBidder(
            msg.sender,
            msg.value,
            block.timestamp
        );
        emit BidPlaced(msg.value, msg.sender, block.timestamp);
        // Emit Bid event
    }

    // fetch Auction
    function fetchAuction(uint256 auctionId) public view {
        return auctions[auctionId];
    }

    // setAuctionEndTime
    function setAuctionEndTime(uint256 auctionId, uint256 _newEndTime) public {
        require(
            msg.sender == auctions[auctionId].seller,
            "you are not the seller"
        );
        require(
            newTIme > block.timestamp && newTime < auctions[auctionId].endTime,
            "We can't set Auctions in the past"
        );
        auctions[auctionId].endTime = newEndTime;
        emit AuctionEndTimeModified(
            _auctionId,
            auctions[auctionId].tokenId,
            msg.sender,
            _newEndTime
        );
        return newEndTime;
    }

    // SetAuctionStartTime
    function setAuctionStartTime(uint256 _auctionId, uint256 _newStartTime)
        public
    {
        require(
            msg.sender == auctions[auctionId].seller,
            "you are not the seller"
        );
        require(
            newTIme > block.timestamp && newTime < auctions[auctionId].endTime,
            "We can't set Auctions in the past"
        );
        auctions.startTime = newTime;
        emit AuctionStartTimeModified(
            _auctionId,
            auctions[auctionId].tokenId,
            msg.sender,
            _newStartTime
        );

        return newTime;
    }

    // ResultAuction
    function resultAuction(uint256 auctionId) public payable {
        require(
            block.timestamp > auctions[auctionId].endTime,
            "Auction hasn't ended yet"
        );
        require(
            msg.sender == auctions[auctionId].seller,
            "Sender not the Seller"
        );
        require(
            nftContract.ownerOf(auctions[auctionId].tokenId) == msg.sender &&
                nftContract.isApprovedForAll(msg.sender, address(this)),
            "Operator or contract not approved"
        );
        HighestBidder highestBidder = highestBids[auctions[auctionId].tokenId];
        nftContract.safeTransferFrom(msg.sender, highestBidder.bidder);
        payable(msg.sender).transfer(highestBidder.bid);
        delete highestBids[auctions[auctionId].tokenId];
        emit AuctionResulted(
            auctions[auctionId].seller,
            msg.sender,
            highestBidder.bid,
            block.timestamp
        );
        // Emit AuctionResulted
    }

    // withdraw auction amount

    function withdrawAuction() public payable onlyAuthorized {
        payable(msg.sender).transfer(address(this).balance);
        AuctionBalanceWithdrawn(
            msg.sender,
            address(this),
            address(this).balance
        );
    }

    function updateNftContract(address _nftContract) public onlyAuthorised {
        realIncomNftContract = RealIncomNft(_nftContract);
        emit NFTContractUpdated(_nftContract, msg.sender);
    }

   

    function updateAccessControlContract(address _accessController) public onlyAuthorised{
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(_accessController, msg.sender);

    }
}


