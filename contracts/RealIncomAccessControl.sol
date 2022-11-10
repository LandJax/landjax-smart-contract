// SPDX-License-Modifier: MIT

pragma solidity ^0.8.7;

contract RealIncomAccessControl is Ownable{
    mapping(address => bool) private admins;
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner")
    }

    function isAdmin (address sender) public returns(bool){
        return admins[sender];
    }

    function makeAdmin (address sender) public onlyOwner{
        admins[sender] = true;
    }
}