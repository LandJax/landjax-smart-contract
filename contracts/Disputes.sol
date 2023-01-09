// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/escrow/Escrow.sol";
import "./LandjaxAuction.sol";
import "./LandjaxAccessControl.sol";

interface AuctionInterface {
    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 reservedPrice;
        bool intergrityConfirmed;
        bool resulted;
        uint256 endTime;
        address seller;
        address buyer;
        bool isOnSale;
        string sellType;
    }
}


/***
 * overall this contract allow users to report dispute
 * when Digital asset sale doesn't go as planned
 * users can report disputes
 * chiefs or authroised personnel can resolve dispute
 * the funds is now transferred to appropriate user after dispute settlement
 */

contract Disputes is Escrow, AuctionInterface {
    address agentOperator;
    landjaxAuction public auctionContract;
    landjaxAccessControl public accessController;

    event DisputeResolved(
        address _fundReceiver,
        uint256 payment,
        uint256 disputeId
    );
    event DisputeReported(
        address disputeReporter,
        uint256 auctionId,
        string _message,
        string _email,
        string _phone,
        bool isSettled
    );
    event AuctionContractUpdated(address _auctionContract, address sender);
    event AccessControlContractUpdated(
        address _accessController,
        address sender
    );
    struct Dispute {
        address seller; //seller is payee
        address buyer;
        uint256 auctionId;
        string messageQuery;
        string email;
        string phone;
        uint256 time;
        bool isSettled;
    }

    mapping(uint256 => Dispute) public disputes;

    uint256 disputeCount;

    constructor(
        landjaxAuction _auctionContractAddreas,
        landjaxAccessControl _accessControllerAddress
    ) {
        auctionContract = landjaxAuction(_auctionContractAddreas);
        accessController = landjaxAccessControl(_accessControllerAddress);
        disputeCount = 0;
    }

    modifier onlyAuthorized() {
        require(
            accessController.isAuthorized(msg.sender),
            "You're not Authorized"
        );
        _;
    }

    function dispute(
        uint256 _auctionId,
        string memory _messageQuery,
        string memory _email,
        string memory _phone
    ) public {
        (
         
            /*bool intergrityConfirmed*/,
            /*bool auctionResulted*/,
            /*uint256 endTime*/,
            address seller
           
        ) = auctionContract.fetchAuction(_auctionId);

        (address bidder, /*uint256 bid*/,  /*uint256 bidTime*/) = auctionContract
            .fetchBid(_auctionId);
        [_auctionId];
        require(
            seller == msg.sender || bidder == msg.sender,
            "You are not involved in this transaction"
        );
        disputes[disputeCount] = Dispute(
            seller,
            bidder,
            _auctionId,
            _messageQuery,
            _email,
            _phone,
            block.timestamp,
            false
        );
        // emit Dispute reported
        emit DisputeReported(msg.sender, _auctionId, _messageQuery, _email, _phone, false);
    }

    function resolveVillageDispute(address _fundReceiver, uint256 _disputeId)
        public
        onlyAuthorized
    {
        auctionContract.resolveAuction(
            disputes[_disputeId].auctionId,
            _fundReceiver
        );
        disputes[_disputeId].isSettled = true;
        (/*address bidder*/, uint256 bid,  /*uint256 bidTime*/) = auctionContract
            .fetchBid(disputes[_disputeId].auctionId);
        emit DisputeResolved(
            _fundReceiver,
            bid,
            _disputeId
        );
    }

    function updateAuctionContract(landjaxAuction _auctionContract)
        public
        onlyAuthorized
    {
        auctionContract = landjaxAuction(_auctionContract);
        emit AuctionContractUpdated(address(_auctionContract), msg.sender);
    }

    function updateAccessControlContract(landjaxAccessControl _accessController)
        public
        onlyAuthorized
    {
        accessController = landjaxAccessControl(_accessController);
        emit AccessControlContractUpdated(address(_accessController), msg.sender);
    }
}
