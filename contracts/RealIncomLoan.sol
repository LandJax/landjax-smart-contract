//SPDX-License-Identifer: MIT
pragma solidity ^0.8.7;

import "./RealIncomNft.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract RealIncomLoan is ReentrancyGuard{

    RealIncomNft nftContract;
    using SafeMath for uint256;

    constructor(RealIncomNft nftContractAddress){
        nftContract = RealIncomNft(nftContractAddress);
    }

    // borrowerCounter
    uint256 borrowerCounter;

    // LenderCounter
    uint256 loanCounter;

    // emit money loaned event
    event MoneyBorrowed(
       uint256 amountBorrowed,
       uint256 interestRate, //percentage borrower would pay back
       uint256 loanDuration,
       uint256 monthlyRemittance,
       bool isApproved,
       address lender,
       uint256 loanId,
       uint256 borrowId
    );

    event ValueReceived(
        address sender,
        uint256 value
    );

    event LoanRequest(
        uint256 amountBorrowed,
       uint256 interestRate, //percentage borrower would pay back
       uint256 loanDuration,
       uint256 monthlyRemittance,
       bool isApproved,
       address lender,
       uint256 loanId,
       uint256 borrowId
    );

    event LoanCreated(
        uint256 amountSupplied,
        uint256 interestRate, //percentage
        uint256 loanDuration, // loan duration months
        uint256 toBePaidMonthly,
        uint256 roi,
        address lender,
        bool isActive,
        uint256 loanId
    );
    // emit money topped up event
    event MoneyTopped(
        uint256 loanId,
        uint256 amountTopped,
        address sender
    );

    // create Loan struct

    // define a struct for lenders amountSupplied, interestRate, loanDuration, monthlyReturns
    struct Loan{
        amountSupplied: uint256;
        interestRate: uint256; //percentage
        loanDuration: uint256; // loan duration months
        toBePaidMonthly: uint256;
        roi: uint256;
        lender: address;
        isActive: bool;
        lentOut: uint256;
    }

    // create a list of lenders
    mapping(uint256 => Loan) loans;


    // define a struct for borrowers amountBorrowed, interestRate, loanDuration, monthlyRemittance
    struct Borrower{
       uint256git amountBorrowed;
       uint256git interestRate; //percentage borrower would pay back
       uint256git loanDuration;
       uint256git monthlyRemittance;
       boolgit isApproved;
       addressgit lender;
       addressgit borrower;
       uint256git loanId;
       uint256git collateralTokenId;
    }
    // create a list of borrowers
    mapping(uint256 => Borrower) borrowers;

    // create Loan
    function createLoan(
                        uint256 interestRate,
                        uint256 loanDuration,
                        uint256 toBePaidMonthly,
                        uint256 roi,
                        uint256 lender,
                        uint256 isActive ) public payable nonReentrant{
        require(msg.value > 0 && loanDuration > 0 && toBePaidMonthly > 0, "you have insufficient balance for this loan");
        loanCounter += 1;
        loans[loanCounter] = Loan(msg.value, interestRate, loanDuration, toBePaidMonthly, roi, msg.sender, true);

        emit LoanCreated(msg.value, interestRate, loanDuration, toBePaidMonthly, roi, msg.sender, true, loanCounter);
    }

    function withdrawLoan(uint256 _amount, uint256 loanId) public payable nonReentrant{
        require(loans[loanId].lender == msg.sender, "Error withdrawing funds You did not create this Loan");
        require(loans[loanId].amountSupplied >= _amount, "insufficient funds for withdrawal of that amount");
        sendViaCall(msg.sender, _amount);
        emit LoanWithdrawn()
    }

    // create an applyForLoan Function
    function applyForLoan(uint256 collateralTokenId) public  {
        if (loans[_loanId].amountSupplied < _amount){
            revert("The loan amount you seek is bigger than the available loan!");
        }

        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Contract not Approved or not authorised to operator");

        address nftOwner = nftContract.ownerOf(collateralTokenId);
        if(nftOwner != msg.sender){
            revert("Sender not Nft owner");
        }

        nftContract.safeTransferFrom(msg.sender, address(this), collateralTokenId);

        borrowerCounter+= 1;
        borrowers[borrowerCounter] = Borrower(_amount, loans[_loanId].interestRate,  loans[_loanId].loanDuration, loans[_loanId].toBePaidMonthly, false, loans[_loanId].lender, true);
        emit LoanRequest(_amount, loans[_loanId].interestRate,  loans[_loanId].loanDuration, loans[_loanId].toBePaidMonthly, false, loans[_loanId].lender, msg.sender, true, borrowerCounter, collateralTokenId);
    }

    // create approveLoan function
    function approveLoan(uint256 borrowerId, uint256 loanId) public payable nonReentrant {
        require(loans[loanId].lender == msg.sender, "User not creator of loan");
        require(loans[loanId].amountSupplied > borrowers[borrowerId].amountBorrowed, "Amount to small to loan");

        uint256 amountToSend = borrowers[borrowerId].amountBorrowed;
        uint256 loans[loanId].amountSupplied.sub(amountToSend);
        uint256 loans[loanId].lentOut.add(amountToSend);
        sendViaCall(address(this), amountToSend);
        // transfer nft to smart contract
        emit MoneyBorrowed();
    }

    function payBackLoan(uint256 loanId, uint256 borrowerId) public payable nonReentrant{
        uint256 loanInterest = borrowers[borrowerId].amountBorrowed.div(100.mul(1e18)).mul(loans[loanId].interestRate);
        uint256 baseAmount = borrowers[borrowerId].amountBorrowed;
        uint256 amountToPayBack = loanInterest.add(baseAmount);
        if(amountToPayBack > msg.value){
            console.log("Please Top up, you do not have sufficient funds to payback")
        }

        borrowers[borrowerId].amountBorrowed = borrowers[borrowerId].amountBorrowed.sub(amountToPayBack);
        loans[loanId].lentOut = loans[loanId].lentOut.sub(amountToPayBack);
        loans[loanId].amountSupplied = loans[loanId].amountSupplied.add(amountToPayBack);
        emit LoanPayed(amountToPayBack, loans[loanId].lender, borrowers[borrowerId].borrower, loanId, borrowId);
    }

    // create topUpLoan function
    function topUpLoan(uint256 loanId) public {
        require(loans[loanId].lender == msg.sender, "An error: it seems you did not instantiate this loan");
        loans[loanId].amountSupplied.add(msg.value);
        emit MoneyTopped(loanId, msg.value, msg.sender);
    }


     // Function to receive Ether. msg.data must be empty
    receive() external payable {
        emit ValueReceived(msg.sender, msg.value);
    }

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

  
}

