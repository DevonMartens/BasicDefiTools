// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract EtherStorageWallet {
    uint public unlockTime;
    address payable public owner;

    event Withdrawal(uint amount, uint when);

    address public payable owner;

    constructor(address _owner) {
        owner = _owner
    }

    function deposit() external payable {

    }

    function withdraw(address payable reciever, uint256 amount) external {

       if(msg.sender == owner){
           reciever.transfer(amount);
           return;
       }else {
           revert("ONLY_OWNER_ALLOWED")
       }
    }

    function balanceOf() public view returns(uint256){
        return address(this).balance;
    }
}
