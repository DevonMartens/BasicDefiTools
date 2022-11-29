// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;


contract BasicEscrow {

    address public buyer;

    address payable public seller;

    address public escrowParty;

    uint public amount;


 

    constructor(address _buyer, address _seller, uint _amount) {
        buyer = _buyer;
        seller = _seller;
        escrowParty = msg.sender;
        amount = _amount;
    }

    function deposit() external payable {
        if(msg.sender =! buyer){
            revert("NOT_APPROVED_BUYER")
        }
        if(address(this).balance >= amount){
            revert("CONTRACT_BALANCE_MORE_THAN_ESTATE")
        }
    
    modifer onlyEscrowParty{
        require(msg.sender == escrowParty, "YOU_ARE_NOT_ESCROWP");
    }
    
    function release() external onlyEscrowParty(){
        if(address(this).balance == amount){
            seller.transfer(amount)
           
        } else {
            revert("NOT_ENOUGH_FUNDS");
        }

    }

    }
  
}