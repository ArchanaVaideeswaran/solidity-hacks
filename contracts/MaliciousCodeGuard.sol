// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Foo {
    Bar public bar;

    // deploying the contract Bar in the constructor and
    // storing it's address public reduces the attack surface.
    constructor() {
        bar = new Bar();
    }

    function callBar() public {
        bar.log();
    }
}

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}
