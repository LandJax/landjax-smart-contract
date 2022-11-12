// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract RealIncomAccessControl{
    mapping(address => bool) private admins;
    address private owner;

    constructor(){
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    event AdminCreated(address admin, bool isAdmin);

    function isAuthorized(address sender) public view returns(bool){
        return (sender == owner || admins[msg.sender]);
    }

    modifier onlyAuthorized {
        require(msg.sender == owner || admins[msg.sender], "only Authorized Personnel are allowed");
        _;
    }



    function isAdmin (address sender) public view returns(bool){
        return admins[sender];
    }

    function makeAdmin (address sender) public onlyAuthorized{
        admins[sender] = true;
        emit AdminCreated(sender, admins[sender]);
    }
}

//  function updateNftContract(address _nftContract) public onlyAuthorised{
//          realIncomNftContract = RealIncomNft(_nftContract);
//     }

//     function updateVillageSquare(address _villageSquareContract) public onlyAuthorised{
//          accessController = VillageSquare(_villageSquareContract);
//     }