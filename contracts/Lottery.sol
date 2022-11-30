// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

// dont use this with out chainlink users can see this in mem pool
contract Lottery {

    enum State {
        IDLE, //defulat
        BETTING
    }
    //players
    address payable[] public players;
    //sets a default current state
    State public currentState = State.IDLE;
    //storage for max number of players
    uint16 public maxPlayers;
    //same bet amountn 
    uint32 public minBetReq;
    //house takes money
    uint256 public houseFee;
    //storage for admin address
    address public admin;

    constructor(uint256 fee){
        require(fee > 1, "NO_ZERO_FEE");
        admin = msg.sender;
        houseFee = fee;
        
    }
    // function to create bet and change enum to active
    function createRound(uint16 numPlayers, uint256 betMoney) external inState(State.IDLE) onlyAdmin {
        maxPlayers = numPlayers;
        minBetReq = betMoney;
        currentState = BETTING;

    }

    //place bet

    function placeBet() external payable inSate(State.BETTING){
        if(msg.value > minBetReq){
            revert("NO_CHEAPNESS");
        }
        //players is payable so address needs to be
        players.push(payable(msg.sender));
        if(maxPlayers == players.length){
        
        }
        uint256 winner = pickAWinner(maxPlayers);
        players[winner].transfer((minBetReq * maxPlayers) * (100 - houseFee) / 100);
        //reset 
        currentState = State.IDLE;
        delete players;
    }
    // cancel game
    function cancelGame()external inState(State.BETTING) onlyAdmin {
        for(uint256 i = 0; players.length; i++){
            players[i].tranfer(minBetReq);
              //reset 
            currentState = State.IDLE;
            delete players;
        }

    }
    //play game
    function pickAWinner(uin256 players) internal {
        uint256 randomNumber;
        //abi encode packed takes arguments and hashes them
        //keccak produce hash
        //cast integer
        randomNumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        //ensure its never greater than number of players
        randomNumber = randomNumber % players;
        return randomNumber;
    }


        /**  
    ================================================
    |                  Modifier                    |
    ================================================
    **/
    
    modifier onlyAdmin() {
        require(
            msg.sender == admin 
            "YOU_ARE_NOT_ADMIN"
            );
            _;
    }
    //takes a state 
    //compares it to current state
    //this allows for function to require betting mode or idel

    modifier inState(State state) {
        require(
            state == currentState
            "INVALID_CURRENT_STATE"
            );
            _;
    }
   
}