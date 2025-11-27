// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract FunctionModifier {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function changeOwner(
        address _newOwner
    ) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }

    uint public x = 10;
    bool public locked;

    modifier noReentrancy() {
        require(locked == false, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function decrement(uint i) public noReentrancy {
        require(x >= i, "Underflow risk");
        while (i > 0) {
            // ✅ 用循环替代递归
            x -= i;
            i--;
        }
    }
}
