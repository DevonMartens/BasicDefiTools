/*
* The seller can be multiple people. You may need to keep track of this using an array
The escrow party address can be changed to a different address at any point in the future with a new function called “changeEscrow” that should only able to be called if you’re an escrow party yourself
Anyone should be able to deposit to the escrow and not just the buyer
You should be able to send any amount of money to the escrow. It doesn’t need to be the exact amount
You may also need to update the release function to account for the above new conditions
Releasing the escrow funds will send Ether to the multiple sellers if any in equal ratio
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;


contract PublicEscrow {
    //public mapping address to itemID
    mapping(address payable [] => uint) public sellerToItemId;
    //public mapping itemID to amount
    mapping(uint => uint) public pricing;
    ///public mapping buyeraddress to amount
    mapping(adress => uint) public buyerPaid;
    ///public mapping itemID to buyeraddress  
    mapping(uint => address) public buyerItemIdOfIntrest;
    //mapping public itemid and isSold
    mapping(uint => bool) public isSold;
    //mapping public itemid and isPendingSale
    mapping(uint => bool) public isPendingSale;
    //tracking for itemID
    uint256 public ItemId;

    //event
    event ItemSold(uint256 indexed ItemId, address indexed buyer);

   function resetItemId() external onlyEscrowParty(){
   //require all items sold
   for (uint i = 0; i < ItemId.length; i++) {
            if (isSold[i] == false) {
                revert("ITEMS_STILL_PENDING_SALE");
                return i;
            }
        }
       ItemId = 0;
   }



    address public escrowParty;

    //uint public amount;


 

    constructor(address _buyer, address _seller, uint _amount) {
        //buyer = _buyer;
        //seller = _seller;
        escrowParty = msg.sender;
        //amount = _amount;
    }

    function listItem(uint256 listPrice) external {
        //public mapping address to itemID
        sellerToItemId[msg.sender] == ItemId;
        //public mapping itemID to amount
        pricing[ItemId] == listPrice;
        //add to itemId to aviod over writing
        ItemId++;
    
    }

    
    
    function deposit(uint256 ItemID) external payable {
         //checks if itemid was already isSold
         if(isSold[ItemID] == true){
             revert("ITEM_IS_ALREADY_SOLD")
         }
         //Checks if ItemId is pending already if it is ensures it is to the owner
         if(isPendingSale[ItemID] == true && buyerItemIdOfIntrest[ItemID] =! msg.sender){
             revert("ANOTHER_BUYER_IS_PURCHASING")
         } 
         //if item wasnt pending set it to pending
         //then set buyer to msg.sender
         if(isPendingSale[ItemID] == false) {
             isPendingSale[ItemID] = true;
             buyerItemIdOfIntrest[ItemID] = msg.sender;
         }
         //adds amount to what buyer has paid.
         buyerPaid += msg.value;
             if(pricing[ItemID] >= buyerPaid[msg.sender]){
                 finalizeSale(ItemID, msg.sender);
             } else {
                 return "BUYER_PAID" buyerPaid[msg.sender] && "TOTAL_PRICE" pricing[ItemID];
             }
         }

    modifer onlyEscrowParty{
        require(msg.sender == escrowParty, "YOU_ARE_NOT_ESCROWP");
    }

    function finalizeSale(uint256 id, address buyer) internal {

        emit ItemSold(uint256 indexed ItemId, address indexed buyer);
    }

    }
  
}