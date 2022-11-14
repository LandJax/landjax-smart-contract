// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/escrow/Escrow.sol";
import "./RealIncomAuction.sol";
import "./RealIncomAccessControl.sol";


contract VillageSquare is Escrow{

    address agentOperator;
    RealIncomAuction public auctionContract;
    RealIncomAccessControl public accessController;

    event DisputeResolved(address _fundReceiver, uint256 payment, uint256 disputeId);
    event DisputeReported(address disputeReporter, uint256 auctionId, string _message, string _email, string _phone);

    struct Dispute{
        address seller; //seller is payee
        address buyer; 
        string message;
        string email;
        string phone;
        uint256 time;
    }

    mapping(uint256 => Dispute) private _disputes;

    uint256 disputeCount;

    constructor(address _auctionContract, address _accessController){
        auctionContract = _auctionContract;
        accessController = _accessController;
        disputeCount = 0;

    }


     modifier onlyAuthorized() {
        require(
            accessController.isAuthorized(msg.sender),
            "You're not Authorized"
        );
        _;
    }


    function dispute(address disputeReporter, uint256 _auctionId, string memory _message, string memory _email, string memory _phone) public{
        require(auctionContract.auctions[_auctionId].seller == disputeReporter || auctionContract.auctions[_auctionId].buyer == disputeReporter, "You are not involved in this transaction");
        _disputes[disputeCount] = Dispute(auctionContract.auctions[_auctionId].seller, auctionContract.auctions[_auctionId].buyer, _message, _email, _phone);
        // emit Dispute reported
        emit DisputeReported(disputeReporter, _auctionId, _message, _email, _phone);
    }

    function resolveVillageDispute(address _fundReceiver, uint256 _disputeId) public onlyAuthorized{
        require(_disputes[_disputeId].seller == fundReceiver || _disputes[_disputeId].buyer ==  _fundReceiver, "the Specified fund receiver is not involved in the village dispute specify the token seller or buyer");
        uint256 payment = _deposits[_disputes[_disputeId].seller];
        if (payment == 0){
            payment = _deposits[_disputes[_disputeId].buyer];
            require(payment > 0, "There is no fund reserved for the payee");
        }

        payable(_fundReceiver).transfer(payment);
        emit DisputeResolved(_fundReceiver, payment, _disputeId);
    }

    function updateAuctionContract(address _auctionContract) public onlyAuthorised{
        auctionContract = RealIncomAuction(_auctionContract);
        emit AuctionContractUpdated(_auctionContract, msg.sender);
    }

    function updateAccessControlContract(address _accessController) public onlyAuthorised{
        accessController = RealIncomAccessControl(_accessController);
        emit AccessControlContractUpdated(_accessController, msg.sender);

    }

}
