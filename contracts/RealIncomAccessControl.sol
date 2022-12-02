// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./AddressManager.sol";

contract RealIncomAccessControl{
    mapping(address => bool) private admins;
    address private _owner;
    AddressManager public addressManager;

    constructor(){
        _owner = msg.sender;
        admins[msg.sender] = true;
         
    }

    event AdminCreated(address admin, bool isAdmin);
    event AddressManagerUpdated(address addressManagerAddress, address innitiator);


    function isAuthorized(address sender) public view returns(bool){
        // allow authorized addresses or address manager contract to effect change accross contract.
        return (sender == _owner || admins[sender] || sender == addressManager.addressManagerAddress());
    }

    // define modifier for authorization
    modifier onlyAuthorized {
        require(msg.sender == _owner || admins[msg.sender], "only Authorized Personnel are allowed");
        _;
    }

    // check if sender is admin
    function isAdmin (address sender) public view returns(bool){
        return admins[sender];
    }

    function makeAdmin (address sender) public onlyAuthorized{
        admins[sender] = true;
        emit AdminCreated(sender, admins[sender]);
    }

    function updateAddressManager(address _addressManagerAddress) public onlyAuthorized {
        addressManager = AddressManager(_addressManagerAddress);
        emit AddressManagerUpdated(_addressManagerAddress, msg.sender);

    }
}

//  function updateNftContract(address _nftContract) public onlyAuthorised{
//          realIncomNftContract = RealIncomNft(_nftContract);
//     }

//     function updateVillageSquare(address _villageSquareContract) public onlyAuthorised{
//          accessController = VillageSquare(_villageSquareContract);
//     }