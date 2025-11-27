// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Callee {
    uint public x;
    uint public value;
    function setX(uint _x) public returns (uint) {
        x = _x;
        return x;
    }
    function setXAndSendEther(uint _x) public payable returns (uint, uint) {
        x = _x;
        value = msg.value;
        return (x, value);
    }
}
contract Caller {
    // 0x182A3874a348Bf1101f1957Ff93EEB67D6E4695B,10
    function setX(Callee _callee, uint _x) public {
        _callee.setX(_x);
    }
    // 0x182A3874a348Bf1101f1957Ff93EEB67D6E4695B,10
    function setXFromAddress(address _addr, uint _x) public {
        Callee callee = Callee(_addr);
        callee.setX(_x);
    }
    // 0x182A3874a348Bf1101f1957Ff93EEB67D6E4695B,10
    function setXandSendEther(Callee _callee, uint _x) public payable {
        (uint x, uint value) = _callee.setXAndSendEther{value: msg.value}(_x);
    }
}
