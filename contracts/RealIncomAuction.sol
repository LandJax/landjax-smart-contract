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
    VillageSquare villageSquareContract;
    uint256 minimumBidIncrement = 1e18;
    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 reservedPrice;
        bool intergrityConfirmed;
        bool auctionResulted;
        uint256 endTime;
        address seller;
        bool isOnSale;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 auctionIdCounter;

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

    event ValueSent(
        address indexed to,
        uint256 indexed val
    )

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
            "entity or contract is not Authorized"
        );
        _;
    }

    constructor(address _incomNft, address _accessController) {
        nftContract = RealIncomNft(_incomNft);
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
            false;
            false;
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
        auctions[_auctionId].isOnSale = false;
        emit AuctionCancelled(
            _auctionId,
            auctions[auctionId].tokenId,
            msg.sender
        );
    }

     // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // Place Bid

    function sendViaCall(address payable _to, uint256 _amountvalue) private payable{
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: _amountvalue}("");
        require(sent, "Failed to send Matic");
        emit ValueSent(_to, _amountvalue);
    }

    function placeBid(uint256 _auctionId) public payable {
        require(
            block.timestamp < auctions[_auctionId].endTime,
            "Auction has ended"
        );

        require(msg.sender !=  auctions[_auctionId].seller, "you should are not allowed to place a bid on your own auction.")
        require(msg.sender != address(0), "this is the address 0x00.. address");
        HighestBidder highestBidder = highestBids[_auctionId];
        uint256 minBid = highestBidder.bid.add(minimumBidIncrement);
        if (highestBidder.bid == 0) {
            minBid = highestBids[_auctionId].reservedPrice.add(
                    minimumBidIncrement
                );
        }

        require(msg.value > minBid, "You did not outbid the highest bidder");

        payable(highestBidder.bidder).transfer(highestBidder.bid);
        sendViaCall(highestBidder.bidder, highestBidder.bid);
        delete highestBids[auctions[_auctionId].tokenId];
        highestBids[_auctionId] = HighestBidder(
            msg.sender,
            msg.value,
            block.timestamp
        );
        nftContract.setNftValue(msg.value);
        emit BidPlaced(msg.value, msg.sender, block.timestamp);
        // Emit Bid event
    }

    function resolveAuction(uint256 _auctionId, address _to) public payable onlyAuthorised{
        require(highestBids[_auctionId].bid > 0, "0 bid was placed no funds to cashback");
        require(highestBids[_auctionId].bidder == _to || auctions[_auctionId].seller == _to, "user address not involved in the bid process");
        sendViaCall(_to, highestBids[_auctionId].bid);
    }

    // fetch Auction
    function fetchAuction(uint256 auctionId) public view {
        return auctions[auctionId];
    }

    // setAuctionEndTime
    function setAuctionEndTime(uint256 _auctionId, uint256 _newEndTime) public {
        require(
            msg.sender == auctions[auctionId].seller,
            "you are not the seller"
        );
        require(
            _newEndTime > block.timestamp && _newEndTime < auctions[auctionId].endTime,
            "We can't set Auctions in the past"
        );
        auctions[auctionId].endTime = _newEndTime;
        emit AuctionEndTimeModified(
            _auctionId,
            auctions[_auctionId].tokenId,
            msg.sender,
            _newEndTime
        );
        return _newEndTime;
    }

    // SetAuctionStartTime
    function setAuctionStartTime(uint256 _auctionId, uint256 _newStartTime)
        public
    {
        require(
            msg.sender == auctions[_auctionId].seller,
            "you are not the seller"
        );
        require(
            _newStartTime > block.timestamp && _newStartTime < auctions[_auctionId].endTime,
            "We can't set Auctions in the past"
        );
        auctions.startTime = _newStartTime;
        emit AuctionStartTimeModified(
            _auctionId,
            auctions[_auctionId].tokenId,
            msg.sender,
            _newStartTime
        );

        return _newStartTime;
    }

    // ResultAuction
    // should transfer cash to village square escrow contract.
    // when auction ends user funds should be sent to escrow service
    // Nft should be sent to highest bidder to checkout and verify fun release
    function resultAuction(uint256 _auctionId) public payable {
        require(
            block.timestamp > auctions[_auctionId].endTime,
            "Auction hasn't ended yet"
        );
        require(
            msg.sender == auctions[_auctionId].seller,
            "Sender not the Seller"
        );
        require(
            nftContract.ownerOf(auctions[_auctionId].tokenId) == msg.sender &&
                nftContract.isApprovedForAll(msg.sender, address(this)),
            "Operator or contract not approved"
        );
        HighestBidder highestBidder = highestBids[_auctionId];
        nftContract.safeTransferFrom(msg.sender, highestBidder.bidder);
        auctions[_auctionId].resulted = true;
        auctions[_auctionId].onSale = false;
        // payable(msg.sender).transfer(highestBidder.bid);
        // address(villageSquareContract)
        emit AuctionResulted(
            auctions[_auctionId].seller,
            msg.sender,
            highestBidder.bid,
            block.timestamp
        );
        // Emit AuctionResulted
    }

    function confirmResults(uint256 _auctionId) public payable {
        let highestBidder = highestBids[_auctionId];
        require(highestBidder.bidder == msg.sender, "You did not place a bid on this auction");
        require(block.timestamp > auctions[_auctionId].endTime, "Auction hasn't ended yet");
        require(auctions[_auctionId].intergrityConfirmed, "this Auction has been resulted and settled");
        require(auctions[_auctionId].resulted == true, "Seller has not resulted Auction");
        require(auctions[_auctionId].isOnSale == false, "Seller has not resulted Auction");
        auctions[_auctionId].intergrityConfirmed = true;
        sendViaCall(auctions[_auctionId].seller, highestBidder.bid);
        // emit ResultsConfirmed
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


