/*
Update the “Lottery” contract from the lecture so that the admin should be able to create multiple bets rather than just one at a time.
Bonus: Update the code so that one user can only bet once rather than multiple times.
*/
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// dont use this with out chainlink users can see this in mem pool
contract Lottery {

    enum State {
        IDLE, //defulat
        BETTING
    }
    //struct for player 
    struct LotteryPlayer {
        address payable playerAddress;
        uint id;
        State state;
    }
    //mapping id and state
    mapping(uint => State) public gameState;

    //mapping between struct and address
    mapping (address => LotteryPlayer) public playerStructs;
    //players
    address payable[] public players;
    //sets a default current state
    State public currentState = State.IDLE;
    //storage for max number of players
    uint public maxPlayers;
    //same bet amountn 
    uint public minBetReq;
    //house takes money
    uint public houseFee;
    //storage for admin address
    address public admin;

    constructor(uint fee){
        require(fee > 1, "NO_ZERO_FEE");
        admin = msg.sender;
        houseFee = fee;
        
    }
    // function to create bet and change enum to active
    function createRound(uint numPlayers, uint betMoney) external inState(State.IDLE) onlyAdmin {
        maxPlayers = numPlayers;
        minBetReq = betMoney;
        currentState = State.BETTING;

    }
    //view to check game state 


    //place bet

    function placeBet() external payable inState(State.BETTING) {
        if(msg.value > minBetReq) {
            revert("NO_CHEAPNESS");
        }
        //players is payable so address needs to be
        players.push(payable(msg.sender));

        if(maxPlayers == players.length) { 
        uint winner = pickAWinner(maxPlayers);
        players[winner].transfer((minBetReq * maxPlayers) * (100 - houseFee) / 100);
        //reset 
            currentState = State.IDLE;
        delete players;
       
        }
     
    }
    // cancel game
    function cancelGame()external inState(State.BETTING) onlyAdmin {
        for(uint i =0; i < players.length; i++){
            players[i].transfer(minBetReq);
           
        }
         //reset 
            currentState = State.IDLE;
            delete players;
          
    }
    //play game
    function pickAWinner(uint totalPlayers) internal returns(uint) {
        uint randomNumber;
        //abi encode packed takes arguments and hashes them
        //keccak produce hash
        //cast integer
        randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        //ensure its never greater than number of players
        randomNumber = randomNumber % totalPlayers;


        return randomNumber;
    }


        /**  
    ================================================
    |                  Modifier                    |
    ================================================
    **/
    
    modifier onlyAdmin() {
        require(
            msg.sender == admin, 
            "YOU_ARE_NOT_ADMIN"
            );
            _;
    }
    //takes a state 
    //compares it to current state
    //this allows for function to require betting mode or idel

    modifier inState(State state) {
        require(
            state == currentState,
            "INVALID_CURRENT_STATE"
            );
            _;
    }
   
}