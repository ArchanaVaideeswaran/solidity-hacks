// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    /*tx.origin returns the address of the call of this function
    * rather than the initiator of the tx
    * eg. A -> B and B -> C then msg.sender => address(B)
    * while tx.origin => address(A)
    * this reduces the attack surface.
    */
    function transfer(address payable _to, uint _amount) public {
        require(msg.sender == owner, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}
