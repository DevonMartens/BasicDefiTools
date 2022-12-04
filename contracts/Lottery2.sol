// SPDX-License-Identifier: MIT
/*
    WARNING: NOT AUDITED
*/

pragma solidity ^0.8.16;

contract Solution {

    /**  
    ================================================
    |               State Variables                |
    ================================================
    **/

    // Keep track of the current state of the betting round
    enum State {
        IDLE,
        BETTING
    }

    uint public index;

    struct Game {
        address payable[] players;
        State currentState;
        uint maxPlayers;
        uint minBetReq;
    }
    // An array of Game structs
    Game[] public games;

    // House will take some fee for each round
    uint public houseFee;

    // Storage for admin address
    address public admin;

    /**  
    ================================================
    |               Constructor.                   |
    ================================================
    **/

    constructor(uint fee) {
        require(fee > 0, "Fee should be greather than 1");
        admin = msg.sender;
        houseFee = fee;
    }

    /**  
    ================================================
    |              Game Functions.                 |
    ================================================
    **/

    // Create a new game & change the state to State.BETTING
    function createRound(uint numPlayers, uint betMoney) external onlyAdmin {
        address payable[] memory _players;
        games.push(
            Game({
                players: _players,
                currentState: State.BETTING,
                maxPlayers: numPlayers,
               minBetReq: betMoney
            })
        );
        index++;
    }

    // Allow the players to bet =
    // When we reach the max number of players, we decide the winner
    function bet(uint gameId) external payable inState(
        gameId, 
        State.BETTING) {
        uint minBetReq = games[gameId].minBetReq;
        require(
            msg.value >= minBetReq,
            "WRONG_AMOUNT"
        );

        uint maxPlayers = games[gameId].maxPlayers;
        address payable[] storage players = games[gameId].players;
        players.push(payable(msg.sender));
        if (players.length == maxPlayers) {
            // Pick a winner
            uint winner = _randomNumber(maxPlayers);
            // (moneyRequiredToBet * maxPlayers) is the total amount of money 
            // (100 - houseFee) / 100 takes $ after house
            address payable winnerPlayer = payable(players[winner]);
            winnerPlayer.transfer(
                ((minBetReq * maxPlayers) * (100 - houseFee)) / 100
            );
            // Cleanup the data by removing the betting round data
            delete games[gameId];
        }
    }

    // Cancel the current betting round which will change the state to State.IDLE
    // return funds
    function cancelGame(uint gameId)
        external
        inState(gameId, State.BETTING)
        onlyAdmin
    {
        State currentState = games[gameId].currentState;
        uint minBetReq = games[gameId].minBetReq;
        address payable[] storage players = games[gameId].players;
        for (uint i = 0; i <= players.length - 1; i++) {
            address payable player = payable(players[i]);
            player.transfer(minBetReq);
        }
        delete games[gameId];
        currentState = State.IDLE;
    }

    function _randomNumber(uint _number) internal view returns (uint) {
     
        return
            uint(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty))
            ) % _number;
    }

    /**  
    ================================================
    |                  Modifiers                   |
    ================================================
    **/

    modifier inState(uint gameId, State state) {
        State currentState = games[gameId].currentState;
        require(state == currentState, "WRONG_STATE");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN");
        _;
    }
}