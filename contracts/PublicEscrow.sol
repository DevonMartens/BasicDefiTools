/*
* 
The seller can be multiple people. You may need to keep track of this using an array
The escrow party address can be changed to a different address at any point in the future with a new function called “changeEscrow” that should only able to be called if you’re an escrow party yourself
Anyone should be able to deposit to the escrow and not just the buyer
You should be able to send any amount of money to the escrow. It doesn’t need to be the exact amount
You may also need to update the release function to account for the above new conditions
Releasing the escrow funds will send Ether to the multiple sellers if any in equal ratio
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract PublicEscrow is ReentrancyGuard {

    /**  
    ================================================
    |                  Mappings                    |
    ================================================
    **/

    //public mapping address to itemID to number of seller
    mapping(uint => uint) public NumberOfSellers;
    //public mapping address to itemID to number of seller
    mapping(uint => address) public SecondSeller;
    //mapping bool and itenid
    mapping(uint => bool) public SecondSellerAdded;
    //mapping bool and itenid
    mapping(uint => bool) public ThirdSellerAdded;
    //public mapping address to itemID to number of seller
    mapping(uint => address) public ThirdSeller;
    //public mapping address to itemID
    mapping(address => uint) public sellerToItemId;
    //public mapping address to itemID
    mapping(uint => address) public ItemIdToSeller;
    //public mapping itemID to amount
    mapping(uint => uint) public pricing;
    ///public mapping buyeraddress to amount
    mapping(address => uint) public buyerPaid;
    ///public mapping itemID to buyeraddress  
    mapping(uint => address) public buyerItemIdOfIntrest;
    //mapping public itemid and isSold
    mapping(uint => bool) public isSold;
    //mapping public itemid and isPendingSale
    mapping(uint => bool) public isPendingSale;
    
    /**  
    ================================================
    |                Global Variables              |
    ================================================
    **/

    //tracking for itemID
    uint256 public ItemId;
    //storage for escrow contract
    address public escrowParty;

    //event
    event ItemSold(uint256 indexed ItemId, address indexed buyer);
    //event for deposit
    event PaymentMade(uint256 indexed Price, uint256 indexed Paid, address PossibleBuyer);

    /**  
    ================================================
    |               Setter Functions               |
    ================================================
    **/

    function setEscrowPartyAddress(address newEscrowAddress) external onlyEscrowParty() {
        escrowParty = newEscrowAddress;
    }

   function resetItemId() external onlyEscrowParty() {
    require(checkSalesEnded() == false, "SALES_PENDING");
       ItemId = 0;
   }

   function checkSalesEnded() public view returns (bool) {
        for (uint i = 0; i < ItemId; i++) {
            if (isSold[i] == false) {
                return true;
            } 
            return false;
        } 
   }



   
    /**  
    ================================================
    |                  Modifier                    |
    ================================================
    **/
    
    modifier onlyEscrowParty() {
        require(
            msg.sender == escrowParty, 
            "YOU_ARE_NOT_ESCROW"
            );
            _;
    }

    /**  
    ================================================
    |             Constructor                      |
    ================================================
    **/

    // casts contract deployer as escrowParty
    constructor() {
        escrowParty = msg.sender;
    }

    /**  
    ================================================
    |           Sales Functions                    |
    ================================================
    **/

    /*
    @Dev: Allows seller to list items.
    @Params: The arugment `uint256 numSellers` number of sellers the item has.
    @Params: The arugment ``uint256 listPrice`` price user wants for item.
    @Notice: User has to have an active sale.
    */  

    function listItem(uint256 listPrice, uint256 numSellers) external nonReentrant {
        //public mapping address to itemID
        sellerToItemId[msg.sender] = ItemId;
        //item id to address
        ItemIdToSeller[ItemId] = msg.sender;
        //public mapping itemID to amount
        pricing[ItemId] = listPrice;
        //mapping public itemid and isSold
         isSold[ItemId] = false;
        //mapping public itemid and isPendingSale
        isPendingSale[ItemId] = true;
        //itemid to number of sellers
        NumberOfSellers[ItemId]  = numSellers;
        ItemId++;
    }

    /*
    @Dev: Function to add sellers to an item that has been listed so they can be paid.
    @Params: The arugment `uint256 ItemIdInQuestion` is the itemId assoicated with the sale.
    @Params: The arugment `address addressToAdd` is the co-seller of the item.
    @Notice: User has to have an active sale.
    */     

    function addSeller(uint256 ItemIdInQuestion, address addressToAdd) external nonReentrant {
        require(sellerToItemId[msg.sender] == ItemIdInQuestion, "ITEM_LISTED_NOT_LISTED_BY_YOU");
        if(NumberOfSellers[ItemIdInQuestion] == 2 &&  SecondSellerAdded[ItemIdInQuestion] == false){
            SecondSeller[ItemIdInQuestion] = addressToAdd;
            SecondSellerAdded[ItemIdInQuestion] = true;
        }
        if(NumberOfSellers[ItemIdInQuestion] == 2 &&  SecondSellerAdded[ItemIdInQuestion] == true){
            revert("SELLERS_ADDED");
        }
        if(NumberOfSellers[ItemIdInQuestion] == 3 &&  SecondSellerAdded[ItemIdInQuestion] == false){
            SecondSeller[ItemIdInQuestion] = addressToAdd;
            SecondSellerAdded[ItemIdInQuestion] = true;
        }
        if(NumberOfSellers[ItemIdInQuestion] == 3 &&  SecondSellerAdded[ItemIdInQuestion] == true){
            ThirdSeller[ItemIdInQuestion] = addressToAdd;
            ThirdSellerAdded[ItemIdInQuestion] = true;
        }
        if(NumberOfSellers[ItemIdInQuestion] == 3 &&  ThirdSellerAdded[ItemIdInQuestion] == true){
            revert("SELLERS_ADDED");
        }
    }

    /*
    @Dev: Function to deposit funds to pay for a listed item.
    @Params: The arugment `uint256 ItemID` is the itemId assoicated with the sale.
    */  
    
    function depositForSelf(uint256 ItemID) external payable nonReentrant {
         //checks if itemid was already isSold
         if(isSold[ItemID] == true){
             revert("ITEM_IS_ALREADY_SOLD");
         }
         //Checks if ItemId is pending already if it is ensures it is to the owner
         require(isPendingSale[ItemID] == true && buyerItemIdOfIntrest[ItemID] == msg.sender || isPendingSale[ItemID] == false, "ANOTHER_BUYER_IS_PURCHASING");
         //if item wasnt pending set it to pending
         //then set buyer to msg.sender
         if(isPendingSale[ItemID] == false) {
             isPendingSale[ItemID] = true;
             buyerItemIdOfIntrest[ItemID] = msg.sender;
              //adds amount to what buyer has paid.
             buyerPaid[msg.sender] += msg.value;
         }
        
            if(pricing[ItemID] <= buyerPaid[msg.sender]){
                 finalizeSale(ItemID, msg.sender);
             } else {
                 //"BUYER_PAID" "TOTAL_PRICE" 
                 uint256 Price = buyerPaid[msg.sender];
                 uint256 Paid = pricing[ItemID];
                 emit PaymentMade(Price, Paid, msg.sender);
             }
    }

    /*
    @Dev: Function to deposit funds to pay for a listed item for another user.
    @Params: The arugment `uint256 ItemID` is the itemId assoicated with the sale.
    @Params: The arugment `address PayingOnBehalfOf` user you buy for.
    */  

    function depositForSelf(uint256 ItemID, address PayingOnBehalfOf) external payable nonReentrant {
        require(buyerItemIdOfIntrest[ItemID] == PayingOnBehalfOf, "NO_SWIPING");
        require(isPendingSale[ItemID] == true, "ITEM_SOLD");
        buyerPaid[PayingOnBehalfOf] += msg.value;
             if(pricing[ItemID] <= buyerPaid[PayingOnBehalfOf]){
                 finalizeSale(ItemID, PayingOnBehalfOf);
             } else {
                 //"BUYER_PAID" "TOTAL_PRICE" 
                 uint256 Price = buyerPaid[PayingOnBehalfOf];
                 uint256 Paid = pricing[ItemID];
                 emit PaymentMade(Price, Paid, PayingOnBehalfOf);
             }
    }



    /*
    @Dev: Function to pay out seller and emit event when sale is done.
    */  


    function finalizeSale(uint256 id, address buyer) internal {
        if(NumberOfSellers[id] == 3){
           uint256 amount = buyerPaid[buyer];
           address addressOne = ItemIdToSeller[id]; 
           address addressTwo = SecondSeller[id];
           address addressThree = ThirdSeller[id];
           payable(address(addressOne)).transfer(amount / 3);
           payable(address(addressTwo)).transfer(amount / 3);
           payable(address(addressThree)).transfer(amount / 3);
           isPendingSale[id] = false;
           isSold[id] = true;
        }
         if(NumberOfSellers[id] == 2){
           uint256 amount = buyerPaid[buyer];
           address addressOne = ItemIdToSeller[id]; 
           address addressTwo = SecondSeller[id];
           payable(address(addressOne)).transfer(amount / 2);
           payable(address(addressTwo)).transfer(amount / 2);
           isPendingSale[id] = false;
           isSold[id] = true;
        }
        if(NumberOfSellers[id] == 1){
           uint256 amount = buyerPaid[msg.sender];
           address addressOne = ItemIdToSeller[id]; 
           payable(address(addressOne)).transfer(amount);
            isPendingSale[id] = false;
           isSold[id] = true;
        }
        emit ItemSold(id, buyer);
    }
  
}