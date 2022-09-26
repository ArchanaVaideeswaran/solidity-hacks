// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract EtherStore {
    mapping(address => uint) public balances;
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /*
    * This function follows Check Effects Interaction (CEI) pattern.
    * Is non reentrant with nonReentrant modifier.
    */
    function withdraw() public nonReentrant {
        uint bal = balances[msg.sender];
        require(bal > 0);

        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Receive is called when EtherStore sends Ether to this contract.
    receive() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
