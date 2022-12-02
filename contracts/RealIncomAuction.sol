// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./RealIncomNft.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./RealIncomAccessControl.sol";
import "./VillageSquare.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RealIncomAuction is Ownable, ReentrancyGuard {
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
        bool resulted;
        uint256 endTime;
        address seller;
        bool isOnSale;
        string sellType;
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
        uint256 auctionId,
        uint256 tokenId,
        uint256 startTime,
        uint256 reservedPrice,
        bool intergrityConfirmed,
        bool resulted,
        uint256 endTime,
        address seller,
        bool isOnSale,
        string sellType
    );

    event NFTContractUpdated(
        address indexed _nftContract,
        address indexed sender
    );
    event AccessControlContractUpdated(
        address indexed _accessController,
        address indexed sender
    );

    event BidPlaced(
        uint256 BidAmount,
        address Bidder,
        uint256 bidTime,
        uint256 auctionId,
        uint256 tokenId
    );

    event AuctionCancelled(uint256 auctionId, uint256 tokenId, address seller);

    event AuctionStartTimeModified(
        uint256 auctionId,
        uint256 tokenId,
        address seller,
        uint256 startTime
    );

    event ValueSent(address indexed to, uint256 indexed val);

    event AuctionResulted(
        address seller,
        address winner,
        uint256 winningBid,
        uint256 endTime,
        uint256 auctionId
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

        // if (!accessController.isAuthorized(msg.sender)){
        //     revert("entity or contract is not Authorized");
        // }
        _;
    }

    constructor(address _incomNft, address _accessController) {
        nftContract = RealIncomNft(_incomNft);
        accessController = RealIncomAccessControl(_accessController);
        auctionIdCounter = 0;
    }

    // Start Auction
    function startAuction(
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime,
        uint256 reservedPrice
    ) public nonReentrant returns (uint256) {
        auctionIdCounter += 1;
        auctions[auctionIdCounter] = Auction(
            tokenId,
            startTime,
            reservedPrice,
            false,
            false,
            endTime,
            msg.sender,
            true,
            "silver"
        );

        emit AuctionCreated(
            auctionIdCounter,
            tokenId,
            startTime,
            reservedPrice,
            false,
            false,
            endTime,
            msg.sender,
            true,
            "silver"
        );
        return auctionIdCounter;
    }

    // cancel Auction
    function cancelAuction(uint256 _auctionId) public {
        // require(
        //     msg.sender == auctions[_auctionId].seller,
        //     "You are not the seller"
        // );

        if (msg.sender != auctions[_auctionId].seller){
            revert("You are not the seller");
        }

        auctions[_auctionId].isOnSale = false;
        emit AuctionCancelled(
            _auctionId,
            auctions[_auctionId].tokenId,
            msg.sender
        );
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    // Place Bid

    function sendViaCall(
        address _to,
        uint256 _amountvalue
    ) public payable nonReentrant onlyAuthorized {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent /*bytes memory data*/, ) = payable(_to).call{
            value: _amountvalue
        }("");
        // require(sent, "Failed to send Matic");
        if (!sent) {
            revert("Failed to send Matic");
        }
        emit ValueSent(payable(_to), _amountvalue);
    }

    function placeBid(uint256 _auctionId) public payable nonReentrant {
        // require(
        //     block.timestamp < auctions[_auctionId].endTime,
        //     "Auction has ended"
        // );

        if (block.timestamp > auctions[_auctionId].endTime) {
            revert("Auction has ended");
        }

        // require(
        //     msg.sender != auctions[_auctionId].seller,
        //     "you should are not allowed to place a bid on your own auction."
        // );

        if (msg.sender == auctions[_auctionId].seller) {
            revert(
                "you should are not allowed to place a bid on your own auction."
            );
        }

        // require(msg.sender != address(0), "this is the address 0x00.. address");

        if (msg.sender == address(0)) {
            revert("this is the address 0x00.. address");
        }

        HighestBidder memory highestBidder = highestBids[_auctionId];
        uint256 minBid = highestBidder.bid.add(minimumBidIncrement);
        if (highestBidder.bid == 0) {
            minBid = highestBids[_auctionId].bid.add(minimumBidIncrement);
        }

        // require(msg.value > minBid, "You did not outbid the highest bidder");

        if (msg.value < minBid) {
            revert("You did not outbid the highest bidder");
        }

        payable(highestBidder.bidder).transfer(highestBidder.bid);
        sendViaCall(highestBidder.bidder, highestBidder.bid);
        delete highestBids[auctions[_auctionId].tokenId];
        highestBids[_auctionId] = HighestBidder(
            msg.sender,
            msg.value,
            block.timestamp
        );
        nftContract.setNftValue(msg.value, auctions[_auctionId].tokenId);
        emit BidPlaced(
            msg.value,
            msg.sender,
            block.timestamp,
            _auctionId,
            auctions[_auctionId].tokenId
        );
        // Emit Bid event
    }

    function resolveAuction(
        uint256 _auctionId,
        address _to
    ) public payable nonReentrant onlyAuthorized {
        // require(
        //     highestBids[_auctionId].bid > 0,
        //     "0 bid was placed no funds to cashback"
        // );

        if (highestBids[_auctionId].bid < 0) {
            revert("0 bid was placed no funds to cashback");
        }

        // require(
        //     highestBids[_auctionId].bidder == _to ||
        //         auctions[_auctionId].seller == _to,
        //     "user address not involved in the bid process"
        // );

        if (
            highestBids[_auctionId].bidder != _to ||
            auctions[_auctionId].seller != _to
        ) {
            revert("user address not involved in the bid process");
        }

        sendViaCall(_to, highestBids[_auctionId].bid);
    }

    // fetch Auction
    function fetchAuction(
        uint256 _auctionId
    )
        public
        view
        returns (
            uint256 tokenId,
            uint256 startTime,
            bool intergrityConfirmed,
            address seller
        )
    {
        return (
            auctions[_auctionId].tokenId,
            auctions[_auctionId].startTime,
            auctions[_auctionId].intergrityConfirmed,
            auctions[_auctionId].seller
        );
        // return auctions[_auctionId];
    }

    function fetchBid(
        uint256 _auctionId
    ) public view returns (address bidder, uint256 bid, uint256 bidTime) {
        return (
            highestBids[_auctionId].bidder,
            highestBids[_auctionId].bid,
            highestBids[_auctionId].bidTime
        );
        // return highestBids[_auctionId];
    }

    // setAuctionEndTime
    function setAuctionEndTime(
        uint256 _auctionId,
        uint256 _newEndTime
    ) public returns (uint256) {
        // require(
        //     msg.sender == auctions[_auctionId].seller,
        //     "you are not the seller"
        // );

        if (msg.sender != auctions[_auctionId].seller) {
            revert("you are not the seller");
        }

        // require(
        //     _newEndTime > block.timestamp &&
        //         _newEndTime < auctions[_auctionId].endTime,
        //     "We can't set Auctions in the past"
        // );

        if (
            _newEndTime < block.timestamp &&
            _newEndTime > auctions[_auctionId].endTime
        ) {
            revert("We can't set Auctions in the past");
        }

        auctions[_auctionId].endTime = _newEndTime;
        emit AuctionEndTimeModified(
            _auctionId,
            auctions[_auctionId].tokenId,
            msg.sender,
            _newEndTime
        );
        return _newEndTime;
    }

    // SetAuctionStartTime
    function setAuctionStartTime(
        uint256 _auctionId,
        uint256 _newStartTime
    ) public returns (uint256) {
        // require(
        //     msg.sender == auctions[_auctionId].seller,
        //     "you are not the seller"
        // );

        if (msg.sender != auctions[_auctionId].seller) {
            revert("you are not the seller");
        }

        // require(
        //     _newStartTime > block.timestamp &&
        //         _newStartTime < auctions[_auctionId].endTime,
        //     "We can't set Auctions in the past"
        // );

        if ( _newStartTime < block.timestamp &&
                _newStartTime > auctions[_auctionId].endTime) {
            revert("We can't set Auctions in the past");
        }

        auctions[_auctionId].startTime = _newStartTime;
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
        // require(
        //     block.timestamp > auctions[_auctionId].endTime,
        //     "Auction hasn't ended yet"
        // );

        if ( block.timestamp < auctions[_auctionId].endTime) {
            revert("Auction hasn't ended yet");
        }

        // require(
        //     msg.sender == auctions[_auctionId].seller,
        //     "Sender not the Seller"
        // );


        if (  msg.sender != auctions[_auctionId].seller) {
            revert("Sender not the Seller");
        }


        if (  nftContract.ownerOf(auctions[_auctionId].tokenId) != msg.sender &&
                !nftContract.isApprovedForAll(msg.sender, address(this))) {
            revert("Operator or contract not approved");
        }

        // require(
        //     nftContract.ownerOf(auctions[_auctionId].tokenId) == msg.sender &&
        //         nftContract.isApprovedForAll(msg.sender, address(this)),
        //     "Operator or contract not approved"
        // );
        HighestBidder memory highestBidder = highestBids[_auctionId];
        nftContract.safeTransfer(
            msg.sender,
            highestBidder.bidder,
            auctions[_auctionId].tokenId
        );
        auctions[_auctionId].resulted = true;
        auctions[_auctionId].isOnSale = false;
        // payable(msg.sender).transfer(highestBidder.bid);
        // address(villageSquareContract)
        emit AuctionResulted(
            auctions[_auctionId].seller,
            msg.sender,
            highestBidder.bid,
            block.timestamp,
            _auctionId
        );
        // Emit AuctionResulted
    }

    function confirmResults(uint256 _auctionId) public payable nonReentrant {
        HighestBidder memory highestBidder = highestBids[_auctionId];
        // require(
        //     highestBidder.bidder == msg.sender,
        //     "You did not place a bid on this auction"
        // );

        if ( highestBidder.bidder != msg.sender) {
            revert("You did not place a bid on this auction");
        }

        // require(
        //     block.timestamp > auctions[_auctionId].endTime,
        //     "Auction hasn't ended yet"
        // );

        if ( block.timestamp < auctions[_auctionId].endTime) {
            revert("Auction hasn't ended yet");
        }

        // require(
        //     auctions[_auctionId].intergrityConfirmed,
        //     "this Auction has been resulted and settled"
        // );

        if (  !auctions[_auctionId].intergrityConfirmed ) {
            revert("this Auction has been resulted and settled");
        }

        // require(
        //     auctions[_auctionId].resulted == true,
        //     "Seller has not resulted Auction"
        // );

         if (  !auctions[_auctionId].resulted ) {
            revert("Seller has not resulted Auction");
        }

        // require(
        //     auctions[_auctionId].isOnSale == false,
        //     "Seller has not resulted Auction"
        // );

        if (  !auctions[_auctionId].isOnSale ) {
            revert("Seller has not resulted Auction");
        }

        auctions[_auctionId].intergrityConfirmed = true;
        sendViaCall(auctions[_auctionId].seller, highestBidder.bid);
        // emit ResultsConfirmed
    }

    // withdraw auction amount

    function withdrawAuction() public payable onlyAuthorized {
        payable(msg.sender).transfer(address(this).balance);
        emit AuctionBalanceWithdrawn(
            msg.sender,
            address(this),
            address(this).balance
        );
    }

    function updateNftContract(address _nftContract) public onlyAuthorized {
        nftContract = RealIncomNft(_nftContract);
        emit NFTContractUpdated(_nftContract, msg.sender);
    }

    function updateAccessControlContract(
        RealIncomAccessControl _accessController
    ) public onlyAuthorized {
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(address(_accessController), msg.sender);
    }
}
