// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        // using state variables to track the players balance 
        // reduces the attack surface
        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }

    // asking players to withdraw ETH is a pull technique
    // if an attact is performed on this function
    // it affects only the attacker and 
    // the others can continue playing the game.
    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
