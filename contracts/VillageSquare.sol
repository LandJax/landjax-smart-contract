// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/escrow/Escrow.sol";
import "./RealIncomAuction.sol";
import "./RealIncomAccessControl.sol";

interface AuctionInterface {
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
}

contract VillageSquare is Escrow, AuctionInterface {
    address agentOperator;
    RealIncomAuction public auctionContract;
    RealIncomAccessControl public accessController;

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
        string _phone
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
        string message;
        string email;
        string phone;
        uint256 time;
    }

    mapping(uint256 => Dispute) private _disputes;

    uint256 disputeCount;

    constructor(
        address _auctionContractAddreas,
        address _accessControllerAddress
    ) {
        auctionContract = RealIncomAuction(_auctionContractAddreas);
        accessController = RealIncomAccessControl(_accessControllerAddress);
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
        string memory _message,
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
        _disputes[disputeCount] = Dispute(
            seller,
            bidder,
            _auctionId,
            _message,
            _email,
            _phone,
            block.timestamp
        );
        // emit Dispute reported
        emit DisputeReported(msg.sender, _auctionId, _message, _email, _phone);
    }

    function resolveVillageDispute(address _fundReceiver, uint256 _disputeId)
        public
        onlyAuthorized
    {
        auctionContract.resolveAuction(
            _disputes[_disputeId].auctionId,
            _fundReceiver
        );
        (/*address bidder*/, uint256 bid,  /*uint256 bidTime*/) = auctionContract
            .fetchBid(_disputes[_disputeId].auctionId);
        emit DisputeResolved(
            _fundReceiver,
            bid,
            _disputeId
        );
    }

    function updateAuctionContract(address _auctionContract)
        public
        onlyAuthorized
    {
        auctionContract = RealIncomAuction(_auctionContract);
        emit AuctionContractUpdated(_auctionContract, msg.sender);
    }

    function updateAccessControlContract(address _accessController)
        public
        onlyAuthorized
    {
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(_accessController, msg.sender);
    }
}
