// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Fallback {
    event Log(uint gas);

    fallback() external payable {
        emit Log(gasleft());
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    //这个是接收外来的ETH,只要有才能发
    constructor() payable {}
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }
    function sendToFallback(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }
    function callToFallback(address payable _to) public payable {
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
