// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract PublicEtherWallet {

    //public mapping
    mapping(address => uint) public balances;

    constructor() {
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(address payable reciever, uint256 amount) external {

       if(balances[msg.sender] >= amount){
           balances[msg.sender] -= amount;
           reciever.transfer(amount);
           return;
       }else {
           revert("BALANCE_TOO_LOW");
       }
    }

    function balanceOf(address account) public view returns(uint256){
        return balances[account];
    }
}